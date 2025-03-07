extends Node3D

# Variables de sensibilidad para la rotación
var mouse_sensitivity : float = 0.2

# Variables para las velocidades
var forward_speed : float = 0.0
var max_speed : float = 20.0
var acceleration : float = 10.0
var deceleration : float = 10.0

var lateral_speed : float = 0.0
var max_lateral_speed : float = 15.0
var lateral_acceleration : float = 8.0

var vertical_speed : float = 0.0
var max_vertical_speed : float = 10.0
var vertical_acceleration : float = 6.0

# Variables para rotación
var rotation_x : float = 0.0
var rotation_y : float = 0.0

# Variables adicionales para sprint
var sprint_multiplier : float = 5.0
var sprint_acceleration_multiplier : float = 20.0

func _ready() -> void:
	# Capturar el ratón
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Capturar el movimiento del ratón
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity

		# Limitar la inclinación (ángulo en el eje X) para evitar voltear la nave
		rotation_x = clamp(rotation_x, -45.0, 45.0)

		# Aplicar la rotación
		rotation_degrees = Vector3(rotation_x, rotation_y, 0)

func _process(delta: float) -> void:
	if Input.is_action_pressed("exit"):
		get_tree().quit()
		
	# Controlar la velocidad hacia adelante y atrás con W y S
	var current_max_speed = max_speed
	var current_acceleration = acceleration

	if Input.is_action_pressed("spreen"): # Acción de sprint
		current_max_speed *= sprint_multiplier
		current_acceleration *= sprint_acceleration_multiplier

	if Input.is_action_pressed("move_forward"): # Tecla W
		forward_speed += current_acceleration * delta
	elif Input.is_action_pressed("move_backward"): # Tecla S
		forward_speed -= deceleration * delta
	else:
		forward_speed = lerp(forward_speed, 0.0, 0.1)

	# Controlar la velocidad lateral con A y D
	if Input.is_action_pressed("move_left"): # Tecla A
		lateral_speed -= lateral_acceleration * delta
	elif Input.is_action_pressed("move_right"): # Tecla D
		lateral_speed += lateral_acceleration * delta
	else:
		lateral_speed = lerp(lateral_speed, 0.0, 0.1)

	# Controlar la velocidad vertical con Q y E
	if Input.is_action_pressed("move_up"): # Tecla E
		vertical_speed += vertical_acceleration * delta
	elif Input.is_action_pressed("move_down"): # Tecla Q
		vertical_speed -= vertical_acceleration * delta
	else:
		vertical_speed = lerp(vertical_speed, 0.0, 0.1)

	# Limitar las velocidades máximas
	forward_speed = clamp(forward_speed, -current_max_speed, current_max_speed)
	lateral_speed = clamp(lateral_speed, -max_lateral_speed, max_lateral_speed)
	vertical_speed = clamp(vertical_speed, -max_vertical_speed, max_vertical_speed)

	# Movimiento combinado
	var movement = (
		-transform.basis.z * forward_speed + 
		transform.basis.x * lateral_speed +
		transform.basis.y * vertical_speed
	)
	global_translate(movement * delta)
