extends AudioStreamPlayer

var ext: String = ""


func eplay() -> void:
	if playing:
		return
	play(60 / settings.bpm * get_parent().pos + settings.audio_offset + settings.start_time)
	while playing:
		await get_tree().create_timer(60 / settings.bpm).timeout
		if playing:
			get_parent().move_beat(1)


func estop() -> void:
	stop()


func load_buffer(b: PackedByteArray, e: String) -> void:
	ext = e
	if e == "mp3":
		stream = AudioStreamMP3.load_from_buffer(b)
	if e == "wav":
		stream = AudioStreamWAV.load_from_buffer(b)
	if e == "ogg":
		stream = AudioStreamOggVorbis.load_from_buffer(b)


func load_stream(path: String) -> void:
	ext = path.get_extension()
	if ext == "mp3":
		stream = AudioStreamMP3.load_from_file(path)
	if ext == "wav":
		stream = AudioStreamWAV.load_from_file(path)
	if ext == "ogg":
		stream = AudioStreamOggVorbis.load_from_file(path)
