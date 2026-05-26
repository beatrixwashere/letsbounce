extends SpinBox


func new_offset() -> void:
	settings.audio_offset = value / 1000.0
