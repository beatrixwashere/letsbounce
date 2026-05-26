extends Node2D

var s: bool = false
var pos: int = 0
var prev: Sprite2D


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_UP and event.pressed:
			move_beat(1 * (5 if s else 1))
		if event.keycode == KEY_DOWN and event.pressed:
			move_beat(-1 * (5 if s else 1))
		if event.keycode == KEY_SHIFT:
			s = event.pressed
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			move_beat(1 * (5 if s else 1))
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			move_beat(-1 * (5 if s else 1))


func _ready() -> void:
	var b: Node2D = get_node("buttons/base")
	await get_tree().create_timer(0).timeout
	for i in range(1):
		for j in range(4):
			for k in range(4):
				var nb: Node2D = b.duplicate()
				nb.position.x = k * 128
				nb.position.y = (i * 4 + j) * -128
				if j == 2:
					nb.get_node("bar").modulate = Color(1, 0, 0, 0.5)
					pass
				if j == 1 or j == 3:
					nb.get_node("bar").modulate = Color(0, 1, 0, 0.5)
					pass
				if j != 0 or k != 0:
					nb.get_node("label").free()
				else:
					nb.get_node("label").text = str(i)
					nb.name = "o"
				nb.get_node("button").connect("button_down", add_ball.bind(k * 128, (i * 4 + j) * -128))
				get_node("buttons").add_child(nb)
	b.queue_free()


func add_ball(tx: float, ty: float) -> void:
	var nball: Sprite2D = get_node("b").duplicate()
	get_node("balls").add_child(nball)
	nball.position = Vector2(tx + 48, ty - pos * 512)
	nball.visible = true
	if s:
		if not prev:
			nball.queue_free()
			return
		var dist: Vector2 = prev.global_position - nball.global_position
		if dist.y <= 0:
			nball.queue_free()
			return
		prev.modulate = Color(1, 1, 0, 1)
		nball.get_node("line").points = [Vector2.ZERO, dist]
		nball.modulate = Color(1, 1, 0, 1)
		nball.add_ball(ty / -512 + pos, tx / 128, prev)
		prev.add_obj(nball)
	else:
		nball.add_ball(ty / -512 + pos, tx / 128)
		nball.add_obj(nball)
	prev = nball


func back_to_main() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func change_bpm(v: float) -> void:
	settings.bpm = v


func change_start(v: float) -> void:
	settings.start_time = v


func export_map(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if get_node("audio").ext == "":
		get_node("../export/status").text = "no audio loaded"
		return
	if not get_node("../bg/image").texture:
		get_node("../export/status").text = "no background loaded"
		return
	var zip := ZIPPacker.new()
	var err := zip.open(path)
	if err != OK:
		get_node("../export/status").text = error_string(err)
		zip.close()
		return
		
	zip.start_file("balls.lbb")
	var t: Array = [[], [], [], []]
	var sb: String = ""
	for i in get_node("balls").get_children():
		var line: String = ""
		if i.timing.size() > 0:
			for j in i.timing:
				line += str(j.x) + "," + str(j.y) + ";"
				t[int(j.y)].append(j.x * 60 / settings.bpm)
			sb += line + "|"
	zip.write_file(var_to_bytes(sb))
	zip.close_file()
	
	zip.start_file("timing.lbt")
	for i in range(4):
		t[i].sort()
		var dict: Dictionary = {}
		for j in t[i]:
			dict[j] = 0
		t[i] = dict.keys()
	zip.write_file(var_to_bytes(t))
	zip.close_file()
	
	zip.start_file("info.lbi")
	var info_array: Array = []
	info_array.append(get_node("../info/title").text)
	info_array.append(get_node("../info/author").text)
	info_array.append(get_node("../info/bpm").value)
	info_array.append(get_node("../info/starttime").value)
	info_array.append(get_node("../info/difficulty").value)
	info_array.append(get_node("../info/lastbar").value)
	info_array.append(get_node("audio").ext)
	zip.write_file(var_to_bytes(info_array))
	zip.close_file()
	
	zip.start_file("audio." + get_node("audio").ext)
	zip.write_file(get_node("audio").stream.data)
	zip.close_file()
	
	zip.start_file("bg.png")
	zip.write_file(get_node("../bg/image").img.save_png_to_buffer())
	zip.close_file()
	
	zip.close()
	get_node("../export/status").text = "exported successfully!"


func import_map(path: String) -> void:
	var zip := ZIPReader.new()
	zip.open(path)
	
	var sb: String = bytes_to_var(zip.read_file("balls.lbb"))
	var sba: PackedStringArray = sb.split("|", false)
	for i in sba:
		var t: PackedStringArray = i.split(";", false)
		var v: PackedStringArray = t[0].split(",")
		add_ball(float(v[1]) * 128, float(v[0]) * -512)
		if t.size() > 1:
			for j in range(1, t.size()):
				v = t[j].split(",")
				s = true
				add_ball(float(v[1]) * 128, float(v[0]) * -512)
		s = false
	
	var info_array: Array = bytes_to_var(zip.read_file("info.lbi"))
	get_node("../info/title").text = info_array[0]
	get_node("../info/author").text = info_array[1]
	get_node("../info/bpm").value = info_array[2]
	get_node("../info/starttime").value = info_array[3]
	get_node("../info/difficulty").value = info_array[4]
	get_node("../info/lastbar").value = info_array[5]
	get_node("../info/audio").text = "(loaded from lbm)"
	get_node("../info/background").text = "(loaded from lbm)"
	
	get_node("audio").load_buffer(zip.read_file("audio." + info_array[6]), info_array[6])
	
	get_node("../bg/image").load_buffer(zip.read_file("bg.png"))
	
	zip.close()


func move_beat(dir: int) -> void:
	pos += dir
	if pos < 0:
		pos = 0
	get_node("buttons/o").get_node("label").text = str(pos)
	get_node("balls").position.y = pos * 512
