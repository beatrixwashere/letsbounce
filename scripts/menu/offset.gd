extends SpinBox


func _ready() -> void:
	value = settings.audio_offset * 1000.0


func new_offset(v: float) -> void:
	settings.audio_offset = v / 1000.0
