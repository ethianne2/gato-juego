extends RigidBody2D

@onready var jugador = get_tree().get_first_node_in_group("jugador")
signal choco
#
#func _process(delta: float) -> void:
	#$Line2D.add_point(global_position)

func _on_body_entered(body: Node) -> void:
	call_deferred("set_linear_velocity", Vector2(0,0))
	call_deferred("set_freeze_enabled", true)
	choco.emit(global_position)
