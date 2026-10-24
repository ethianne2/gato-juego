extends Area2D
@export var colision : CollisionShape2D

func _ready() -> void:
	$ColorRect.size = colision.shape.size
	$ColorRect.position = colision.position - (colision.shape.size / 2.0)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("jugador_agua"):
		area.get_parent().estado = 1
		if colision.shape is RectangleShape2D:
			area.get_parent().limite_superficie = colision.global_position.y - (colision.shape.size.y / 2.0)
		area.get_parent().borrar_gancho()
		area.get_parent().stop_swing()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("jugador_agua"):
		area.get_parent().estado = 0
