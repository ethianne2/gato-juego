extends CharacterBody2D

enum Estado { TIERRA, AGUA }

@export_category("Movimiento")
@export var velocidad: float = 100.0
@export var salto: float = 300.0
@export var gravedad: float = 981.0
@export var fuerza_emp: float = 50.0

@export_category("Gancho")
@export var projectil: PackedScene = preload("res://escenas/gancho.tscn")
@export var swing_force: float = 400.0
@export var swing_damping: float = 0.99
@export var velocidad_gancho: float = 400.0
@export var vel_recogida_cuerda: float = 100.0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var pivote: Node2D = $pivote
@onready var raycast: RayCast2D = $RayCast2D
@onready var label: Label = $Label
@onready var gancho_pos: Marker2D = $pivote/gancho_pos

var dir: float = 0.0
var botas: bool = false
var estado: Estado = Estado.TIERRA
var puede_mov: bool = true

var gancho_act: bool = false
var actual_gancho: Node2D = null
var is_hooked: bool = false
var hook_pos: Vector2 = Vector2.ZERO
var rope_length: float = 0.0
var limite_superficie: float = 0.0

func _physics_process(delta: float) -> void:
	pivote.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("botas"):
		botas = !botas
	if botas:
		$botas.show()
	else:
		$botas.hide()
		
	label.text = "botas: " + str(botas)
	dir = Input.get_axis("izquierda", "derecha")
	
	if not puede_mov:
		return
		
	if is_hooked:
		_process_swing(delta)
	else:
		match estado:
			Estado.TIERRA:
				if botas:
					velocity.x = (dir * velocidad) / 2
					if is_on_floor():
						if Input.is_action_pressed("salto"):
							velocity.y -= salto
					else:
						velocity.y += gravedad * 2 * delta
						
					velocity.y = clamp(velocity.y, -salto, gravedad)
					
				else:
					velocity.x = dir * velocidad
					if is_on_floor():
						if Input.is_action_pressed("salto"):
							velocity.y -= salto
					else:
						velocity.y += gravedad * delta
						
					velocity.y = clamp(velocity.y, -salto, gravedad)
				
			Estado.AGUA:
				borrar_gancho()
				stop_swing()
				if botas:
					velocity.x = dir * velocidad
					if is_on_floor():
						if Input.is_action_pressed("salto"):
							velocity.y -= salto / 3
					else:
						velocity.y += (gravedad / 3) * delta
						velocity.y = clamp(velocity.y, -salto, 50)
				else:
					velocity.x = dir * (velocidad * 0.75)
					velocity.y -= 50 * delta
					velocity.y = clamp(velocity.y,-salto,20)
						
						#
	#print("Limite superior: ",limite_superficie)
	#print("Global position: ",global_position.y)
	
	move_and_slide()
	
	if raycast.is_colliding():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is RigidBody2D:
				var push_dir = -collision.get_normal()
				collider.apply_central_impulse(push_dir * fuerza_emp)
				
	lanzar()
	animaciones()

func lanzar() -> void:
	if Input.is_action_just_pressed("lanzar"):
		if gancho_act:
			borrar_gancho()
			stop_swing()
			return
			
		var gancho = projectil.instantiate()
		gancho.global_position = gancho_pos.global_position
		gancho.rotation = pivote.global_position.angle_to_point(get_global_mouse_position())
		
		var direccion = Vector2.RIGHT.rotated(gancho.rotation)
		gancho.linear_velocity = direccion * velocidad_gancho
		gancho.choco.connect(start_swing)
		
		get_tree().current_scene.add_child(gancho)
		actual_gancho = gancho
		gancho_act = true

func borrar_gancho() -> void:
	if is_instance_valid(actual_gancho):
		actual_gancho.queue_free()
	gancho_act = false

func animaciones() -> void:
	if is_on_floor():
		if velocity.x != 0:
			anim.play("caminar")
		else:
			anim.play("idle")
	elif estado == 1:
		anim.play("nadar")
		
	else:
		#await get_tree().create_timer(0.1).timeout
		if velocity.y < 0:
			anim.play("salto")
		else:
			await get_tree().create_timer(0.1).timeout
			anim.play("caida")
	
		
	if dir < 0:
		raycast.scale.x = -1 
		sprite.flip_h = true
		$botas.flip_h = true
		
	elif dir > 0:
		raycast.scale.x = 1 
		sprite.flip_h = false
		$botas.flip_h = false

func _process_swing(delta: float) -> void:
	velocity.y += gravedad * delta
	
	var direction = Input.get_axis("izquierda", "derecha")
	if direction != 0:
		velocity.x += direction * swing_force * delta

	velocity *= swing_damping
	
	var vector_to_hook = hook_pos - global_position
	var current_distance = vector_to_hook.length()
	
	if current_distance > rope_length:
		var pull_direction = vector_to_hook.normalized()
		global_position = hook_pos - (pull_direction * rope_length)
		
		var tangent = pull_direction.orthogonal()
		velocity = tangent * velocity.dot(tangent)
		
	# Velocidad de recogida dependiente del delta
	if Input.is_action_pressed("arriba") and rope_length >= 10:
		rope_length -= vel_recogida_cuerda * delta
	if Input.is_action_pressed("abajo"):
		rope_length += vel_recogida_cuerda * delta

func start_swing(target_position: Vector2) -> void:
	hook_pos = target_position
	rope_length = global_position.distance_to(hook_pos)
	is_hooked = true
	
func stop_swing() -> void:
	is_hooked = false
