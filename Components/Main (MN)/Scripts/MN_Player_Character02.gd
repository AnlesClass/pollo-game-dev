extends CharacterBody2D

var state : String
var direction_request : Vector2
var direction_current : Vector2
var position_target : Vector2
var position_start : Vector2
var lerp_progress : float
var player_raycast : RayCast2D

signal orient_raycast(direction)

func _ready():
	## CONFIGURAR...
	# Estado como activo.
	state = "idle"
	# Dirección que queremos como zero.
	direction_request = Vector2.ZERO
	# Dirección que lleva el cuerpo actualmente.
	direction_current = Vector2.ZERO
	# Posición de destino como la actual.
	position_target = position
	# Posición de inicio para mov. constante.
	position_start = position
	# Progreso del lerp.
	lerp_progress = 0.0
	# Raycast del jugador.
	player_raycast = $Player_Raycast

func _process(delta):
	# SELECCIONAR dirección.
	direction_request = Vector2.ZERO
	
	if Input.is_action_pressed("m_left") :
		direction_request = Vector2.LEFT
	if Input.is_action_pressed("m_right") :
		direction_request = Vector2.RIGHT
	if Input.is_action_pressed("m_down") :
		direction_request = Vector2.DOWN
	if Input.is_action_pressed("m_up") :
		direction_request = Vector2.UP

func _physics_process(delta):
	## EN CUALQUIER ESTADO...
	# Orientar el Raycast2D.
	if direction_request != Vector2.ZERO :
		emit_signal("orient_raycast", direction_request)
	
	## ACCIONES PARA ESTADOS ESPECÍFICOS
	match state:
		"idle":
			## Conditions
			if direction_request != Vector2.ZERO and not player_raycast.is_colliding():
				position_target += direction_request * 64
				state = "walk"
				return
			
			## Actions
			move_and_collide(Vector2.ZERO)
		"walk":
			## Conditions
			# En caso de que se haya filtrado una dirección 0.
			if lerp_progress == 1.0:
				# Si no se apunta a otra dirección.
				if direction_request == Vector2.ZERO :
					lerp_progress = 0.0
					state = "idle"
					return
				# Si si apunta a otra dirección.
				else :
					print("GO")
					position_start = position
					position_target = direction_request * 64
					lerp_progress = 0.0
					state = "walk-constant"
					return
			
			## Actions
			lerp_progress = clamp(lerp_progress + delta, 0.0, 1.0)
			position = lerp(position, position_target, lerp_progress)
		"walk-cosntant":
			## Conditions
			# Si el progreso llega a uno se reinicia.
			if lerp_progress == 1 and direction_request != Vector2.ZERO:
				position_start = position
				position_target = direction_request * 64
				lerp_progress = 0.0
			# Si no se está presionando ningún botón se reinicia.
			if direction_request == Vector2.ZERO:
				lerp_progress = 0.0
				state = "idle"
				return
			
			## Actions
			lerp_progress = clamp(lerp_progress + delta, 0.0, 1.0)
			position = lerp(position_start, position_target, lerp_progress)
			
