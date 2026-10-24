extends Node

@export var inicio : Marker2D
@onready var jugador = get_tree().get_first_node_in_group("jugador")

func _ready() -> void:
	if Global.checkpoint == Vector2(0,0):
		Global.checkpoint = inicio.global_position
	jugador.global_position = Global.checkpoint
