extends Sprite2D

var active: int = 0


func new_active() -> void:
	active += 1
	visible = true


func no_active() -> void:
	active -= 1
	if active == 0:
		visible = false
