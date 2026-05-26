class_name EBall
extends Sprite2D

var timing: Array[Vector2]
var ref: EBall
var objs: Array[EBall]


func add_ball(tx: float, ty: float, prev: EBall = null) -> void:
	if prev:
		ref = prev
	if ref:
		ref.add_ball(tx, ty)
	else:
		timing.append(Vector2(tx, ty))


func add_obj(obj: EBall) -> void:
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
