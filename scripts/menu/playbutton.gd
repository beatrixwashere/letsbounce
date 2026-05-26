extends Button


func play_click(path: String) -> void:
	settings.lbm_path = path
	get_tree().change_scene_to_file("res://scenes/game.tscn")
