extends CharacterBody2D

class_name PlayerBCD

@export var speed = 300.0
@export var waiting_time = 0.15

var size_tile : int = 64
var is_moving : bool = false

# Posiciones
var target

var time_to_walk : float = 0.0
var current_dir : Vector2
var raycast : RayCast2D

# Sirve en caso de un error para devolver al último punto desde el que te moviste.
var last_start_point

func _ready():
	raycast = $Player_Raycast

func _physics_process(delta):
	## BASIC MOVEMENT
	# SELECCIONAR dirección.
	var dir
	if Input.is_action_pressed("m_left") :
		dir = Vector2.LEFT
	if Input.is_action_pressed("m_right") :
		dir = Vector2.RIGHT
	if Input.is_action_pressed("m_down") :
		dir = Vector2.DOWN
	if Input.is_action_pressed("m_up") :
		dir = Vector2.UP
	
	# ESPERAR "waiting_time" para empezar a caminar.
	if dir :
		# Limitar desde 0 al Tiempo_de_Espera suamdno el delta.
		time_to_walk = clamp(time_to_walk + delta, 0, waiting_time)
		# Orientar el Raycast
		raycast.target_position = dir * 50
		
		# TEST
		$Debug_Line.points[1] = dir * 50
	else :
		# Si se deja de pulsa dirección se reinicia el contador.
		time_to_walk = 0
	
	# COMPROBAR si se puede mover :
	if not raycast.is_colliding() and time_to_walk == waiting_time and not is_moving:
		last_start_point = position
		current_dir = dir
		target = position + (dir * size_tile)
		is_moving = true
	
	# MOVER hacia la dirección actual.
	if is_moving :
		walk(delta)
	
	# ACTUALIZAR la animación del sprite.
	draw_sprite()

func walk(delta : float):
	# CORREGIR impacto no deseado
	# NOTE : Este error provocaba que el personaje se quedaba atascado, esta
	# línea de código lo soluciona.
	if move_and_collide(current_dir * speed * delta):
		position = last_start_point
		is_moving = false
	
	# COMPROBAR si se llegó al destino.
	if position.distance_to(target) < 2.5:
		position = target
		is_moving = false

func draw_sprite():
	# look + dir; walk + dir => EX. look_up
	var direction : String = dir_to_text(raycast.target_position.normalized())
	if is_moving:
		$Player_Sprite_Animated.play(str("walk_",direction))
	else :
		$Player_Sprite_Animated.play(str("look_", direction))

## FUNCIONES COMPLEMENTARIAS
func dir_to_text(dir : Vector2):
	if dir == Vector2.UP:
		return "up"
	elif dir == Vector2.DOWN:
		return "down"
	elif dir == Vector2.RIGHT:
		return "right"
	elif dir == Vector2.LEFT:
		return "left"
