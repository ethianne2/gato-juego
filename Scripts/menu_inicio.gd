extends Control


func _on_jugar_pressed() -> void:
	Global.checkpoint = Vector2(0,0)
	get_tree().change_scene_to_file("res://escenas/debug.tscn")


func _on_cerrar_pressed() -> void:
	get_tree().quit()
