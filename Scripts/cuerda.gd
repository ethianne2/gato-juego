extends Line2D

@onready var objeto_a = get_parent()
@onready var objeto_b = get_tree().get_first_node_in_group("jugador")

func _ready():
	set_as_top_level(true)
	
	clear_points()
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)

func _process(_delta):
	if objeto_a and objeto_b:
		set_point_position(0, objeto_a.global_position)
		set_point_position(1, objeto_b.global_position)
