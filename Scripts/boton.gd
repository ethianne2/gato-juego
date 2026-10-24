extends Area2D

var activado : bool
@export_enum("placa","siempre")
var tipo = "placa"

func _process(delta: float) -> void:
	match tipo:
		"placa":
			placa()
		"siempre":
			siempre()
	if activado:
		$Label.text = "activado"
		$ColorRect.color = Color(0.0, 1.0, 0.0, 1.0)
	else:
		$Label.text = "desactivado"
		$ColorRect.color = Color(1.0, 0.0, 0.0, 1.0)
		
		
func siempre():
	if get_overlapping_bodies().size() > 0:
		activado = true

func placa():
	if get_overlapping_bodies().size() > 0:
		activado = true
	else:
		activado = false

	
