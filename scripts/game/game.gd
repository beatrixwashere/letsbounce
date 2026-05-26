extends Node

var timing: Array = [[], [], [], []]
var t: float = 0.0
var accsum: float = 0.0
var balls: int = 0
var bars: Array[Node]
var feedback: Array[Node]
var accs: Array[int] = [0, 0, 0, 0]


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_D:
				hit_ball(0)
			if event.keycode == KEY_F:
				hit_ball(1)
			if event.keycode == KEY_J:
				hit_ball(2)
			if event.keycode == KEY_K:
				hit_ball(3)


func _ready() -> void:
	import_map(settings.lbm_path)
	t -= settings.pre_beats * 60 / settings.bpm
	bars = get_node("bars").get_children()
	feedback = get_node("feedback").get_children()


func _physics_process(_delta: float) -> void:
	t += 1.0 / 60
	for i in range(4):
		if timing[i].size() == 0:
			continue
		if t - timing[i][0] >= 0.3333:
			timing[i].pop_front()
			balls += 1
			update_score()
			feedback[i].text = "[color=red][b]:<"
			feedback[i].modulate.a = 1
			accs[3] += 1
		feedback[i].modulate.a -= 0.05


func hit_ball(l: int) -> void:
	bars[l].self_modulate = Color(1, 1, 0, 1)
	create_tween().tween_property(bars[l], "self_modulate:b", 1, 0.25)
	if timing[l].size() == 0:
		return
	var dist: float = abs(timing[l][0] - t)
	if dist < 0.3333:
		if dist < 0.1:
			accsum += 100.0
			feedback[l].text = "[color=green][b]:3"
			accs[0] += 1
		elif dist < 0.1883:
			accsum += 70.0
			feedback[l].text = "[color=yellow][b]:]"
			accs[1] += 1
		else:
			accsum += 30.0
			feedback[l].text = "[color=orange][b]:/"
			accs[2] += 1
		timing[l].pop_front()
		balls += 1
		update_score()
		feedback[l].modulate.a = 1


func import_map(path: String) -> void:
	var zip := ZIPReader.new()
	zip.open(path)
	
	var sb: String = bytes_to_var(zip.read_file("balls.lbb"))
	var sba: PackedStringArray = sb.split("|", false)
	for i in sba:
		var nball: Ball = get_node("b").duplicate()
		for j in i.split(";", false):
			var v: PackedStringArray = j.split(",")
			nball.timing.append(Vector2(float(v[0]), float(v[1])))
		get_node("balls").add_child(nball)
	
	var tm: Array = bytes_to_var(zip.read_file("timing.lbt"))
	for i in range(4):
		timing[i] = tm[i]
	
	var info_array: Array = bytes_to_var(zip.read_file("info.lbi"))
	get_node("info").text = info_array[0] + "\n\n[font_size=24]"
	get_node("info").text += info_array[1] + "\n\n"
	settings.bpm = info_array[2]
	settings.start_time = info_array[3]
	get_node("info").text += "difficulty: " + str(info_array[4])
	settings.last_bar = info_array[5]
	
	get_node("audio").load_buffer(zip.read_file("audio." + info_array[6]), info_array[6])
	
	get_node("bg/image").load_buffer(zip.read_file("bg.png"))
	
	zip.close()


func update_score() -> void:
	var acc: float = (accsum / balls) if balls > 0 else 100.0
	get_node("score").text = ("%.2f" % acc) + "% (" + str(balls) + ")[font_size=24]\n"
	get_node("score").text += "[color=green]:3[/color] - " + str(accs[0]) + "\n"
	get_node("score").text += "[color=yellow]:][/color] - " + str(accs[1]) + "\n"
	get_node("score").text += "[color=orange]:/[/color] - " + str(accs[2]) + "\n"
	get_node("score").text += "[color=red]:<[/color] - " + str(accs[3]) + "\n\n"
	if acc == 100.0:
		get_node("score").text += "[color=magenta]S++"
	elif acc >= 98.0:
		get_node("score").text += "[color=cyan]S+"
	elif acc >= 95.0:
		get_node("score").text += "[color=cyan]S"
	elif acc >= 92.0:
		get_node("score").text += "[color=green]A+"
	elif acc >= 90.0:
		get_node("score").text += "[color=green]A"
	elif acc >= 85.0:
		get_node("score").text += "[color=yellow]B+"
	elif acc >= 80.0:
		get_node("score").text += "[color=yellow]B"
	elif acc >= 75.0:
		get_node("score").text += "[color=orange]C+"
	elif acc >= 70.0:
		get_node("score").text += "[color=orange]C"
	else:
		get_node("score").text += "[color=red]F"
