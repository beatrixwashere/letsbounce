extends Label

var bpm: float = 142.0
var cur: float = 0

func _physics_process(_delta: float) -> void:
	cur += bpm / 3600
	text = str(floor(cur))
