extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		get_tree().call_deferred("reload_current_scene")
	
	
