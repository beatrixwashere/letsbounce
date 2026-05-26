extends Button


func editor_click() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn")
