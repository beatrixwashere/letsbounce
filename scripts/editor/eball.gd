class_name EditorBall
extends Sprite2D

var timing: Array[Vector2]
var ref: EditorBall
var objs: Array[EditorBall]


func add_ball(tx: float, ty: float, prev: EditorBall = null) -> void:
	if prev:
		ref = prev
	if ref:
		ref.add_ball(tx, ty)
	else:
		timing.append(Vector2(tx, ty))


func add_obj(obj: EditorBall) -> void:
	if ref:
		ref.add_obj(obj)
	else:
		objs.append(obj)


func delete_ball() -> void:
	if ref:
		ref.delete_ball()
	else:
		for i in objs:
			i.queue_free()
