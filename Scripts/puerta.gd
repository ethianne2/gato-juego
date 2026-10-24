extends StaticBody2D

@export var boton : Area2D
@export var colision : CollisionShape2D
var abierta : bool = false
@onready var sprite: TextureRect = $TextureRect

func _process(delta: float) -> void:
	if boton.activado:
		abrir()
	else:
		cerrar()


func abrir():
	colision.disabled = true
	abierta = true
	sprite.hide()
	
func cerrar():
	colision.disabled = false
	abierta = false
	sprite.show()
