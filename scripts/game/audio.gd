extends AudioStreamPlayer


func _ready() -> void:
	await get_tree().create_timer(60 / settings.bpm * settings.pre_beats - settings.audio_offset).timeout
	play(60 / settings.bpm * settings.start_bar + settings.start_time)
	await get_tree().create_timer(60 / settings.bpm * (settings.last_bar - settings.start_bar)).timeout
	await get_tree().create_timer(2).timeout
	create_tween().tween_property(self, "volume_db", -60, 3)
	create_tween().tween_property(get_node("out"), "color:a", 1, 3)
	await get_tree().create_timer(3).timeout
	stop()


func load_buffer(b: PackedByteArray, e: String) -> void:
	if e == "mp3":
		stream = AudioStreamMP3.load_from_buffer(b)
	if e == "wav":
		stream = AudioStreamWAV.load_from_buffer(b)
	if e == "ogg":
		stream = AudioStreamOggVorbis.load_from_buffer(b)
