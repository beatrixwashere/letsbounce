class_name Ball
extends Sprite2D
## basic note object

const BOUNCE_HEIGHT: int = 256
const FALL_RATE: int = 1024
@export var timing: Array[Vector2]


func _ready() -> void:
	if get_parent().name != "balls":
		queue_free()
		return
	for i in range(timing.size()):
		timing[i].x -= settings.start_bar - settings.pre_beats
		if timing[i].x <= 0:
			queue_free()
	position = spawn_pos()
	if timing.size() > 1:
		modulate.b = 0
	start_process()


func bounce_to(l: float, t: float) -> void:
	get_node("/root/game/bars").get_child(int(l)).get_child(0).new_active()
	var tween0 := create_tween()
	var tween1 := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween0.tween_property(self, "position:x", 768 + l * 128, t)
	tween1.tween_property(self, "position:y", 832 - BOUNCE_HEIGHT, t / 2)
	await tween1.finished
	var tween2 := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween2.tween_property(self, "position:y", 832, t / 2)
	await tween2.finished
	get_node("/root/game/bars").get_child(int(l)).get_child(0).no_active()


func fade_out() -> void:
	var tween0 := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var tween1 := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween0.tween_property(self, "position:y", 704, 30 / settings.bpm)
	tween1.tween_property(self, "modulate:a", 0, 30 / settings.bpm)
	await tween0.finished
	queue_free()


func fall_down(t: float) -> void:
	var tween0 := create_tween()
	tween0.tween_property(self, "position:y", 832, t)


func spawn_pos() -> Vector2:
	var res := Vector2(0, 0)
	res.x = 768 + timing[0].y * 128
	res.y = 832 - timing[0].x * FALL_RATE * (60 / settings.bpm)
	return res


func start_process() -> void:
	var prev: float = timing[0].x
	fall_down(timing[0].x * 60 / settings.bpm)
	await get_tree().create_timer(timing[0].x * 60 / settings.bpm).timeout
	timing.pop_front()
	for i in timing:
		var diff: float = i.x - prev
		prev = i.x
		bounce_to(i.y, diff * 60 / settings.bpm)
		await get_tree().create_timer(diff * 60 / settings.bpm).timeout
	fade_out()
