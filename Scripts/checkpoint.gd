extends Area2D

@export var checkpoint : Marker2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		Global.checkpoint = checkpoint.global_position
