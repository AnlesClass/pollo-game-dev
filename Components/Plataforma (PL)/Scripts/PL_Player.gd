extends CharacterBody2D

class_name PlatformPlayer

const SPEED = 110.0 * 60 # Multiplicar por usar 'delta'
const JUMP_VELOCITY = -250.0
const HURT_VELOCITY = 200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var audio_player : AudioStreamPlayer2D
var animator : AnimatedSprite2D
var current_state : STATE = STATE.IDLE
var can_climb : bool = false
var gravity_multiplier : float = 1

var death_sound : AudioStream
var hurt_sound : AudioStream
var jump_sound : AudioStream

enum STATE {
	IDLE,
	WALKING,
	JUMPING,
	FALLING,
	CLIMBING,
	HURT,
	DEATH
}

signal on_hurt

func _init() -> void:
	# AÑADIR al grupo player.
	add_to_group("Player")
	jump_sound = preload("res://Resources/Sounds/jump_03.wav")
	hurt_sound = preload("res://Resources/Sounds/hurt_01.mp3")
	death_sound = preload("res://Resources/Sounds/death_01.wav")

func _ready():
	# INICIALIZAR variables.
	audio_player = get_node("PL_Audio")
	animator = get_node("PL_Sprite_Animated")
	# NOTE. No quiero que ninguna señal se inicialice aquí.

func _input(_event: InputEvent) -> void:
	# OBTENER entrada de movimiento derecha o izquierda.
	var value = Input.get_axis("move_left", "move_right")
	# ORIENTAR segun la entrada.
	if value == -1:
		animator.flip_h = true
	elif value == 1:
		animator.flip_h = false
	
	# NOTE: CONTROL en caso de desactivación de físicas
	if not is_physics_processing():
		animator.play("idle")

#region States
func _physics_process(delta):
	## TODAS LAS POSIBLES COMBINACIONES DE ESTADOS
	match current_state:
		STATE.IDLE: ## NOTE : REVISADO SIN ERRORES
			## FUNCIÓN
			print("State : Idle")
			
			decelerate(0.1)
			animator.play("idle")
			
			## ESTADOS
			# Walking
			if Input.get_axis("move_left", "move_right"):
				current_state = STATE.WALKING
			# Jumping
			elif Input.is_action_pressed("jump") and is_on_floor():
				current_state = STATE.JUMPING
			# Falling
			elif not is_on_floor():
				current_state = STATE.FALLING
			# Climbing:
			elif is_climb() and Input.is_action_pressed("move_up"):
				current_state = STATE.CLIMBING
		STATE.WALKING: ## NOTE : REVISADO SIN ERRORES
			## FUNCIÓN
			print("State : Walking")
			
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = direction * SPEED * delta
			else:
				decelerate(1)
			
			animator.play("walk")
			
			## ESTADOS
			# Climbing
			if is_climb() and Input.get_axis("move_up", "move_down"):
				decelerate(2)
				current_state = STATE.CLIMBING
			# Idle
			elif velocity.x == 0:
				current_state = STATE.IDLE
			# Jumping
			elif Input.is_action_just_pressed("jump") or Input.is_action_pressed("jump"):
				current_state = STATE.JUMPING
			# Falling 
			elif not is_on_floor():
				current_state = STATE.FALLING
		STATE.JUMPING: ## NOTE : REVISADO SIN ERRORES
			## FUNCIÓN
			print("State : Jumping")
			
			# Añadiendo el Multiplicador en este punto se solucionan muchos bugs.
			gravity_multiplier = 1
			
			if is_on_floor():
				# REPRODUCIR audio de muerte.
				audio_player.stream = jump_sound
				audio_player.play()
				# AGREGAR impulso vertical
				velocity.y = JUMP_VELOCITY
			
			## ESTADOS
			# Idle - NOTE : Casi no se usa
			if velocity.y == 0:
				current_state = STATE.IDLE
			# Walking
			elif Input.get_axis("move_left","move_right"):
				current_state = STATE.WALKING
			# Falling
			elif velocity.y > 0:
				current_state = STATE.FALLING
			# Climbing
			elif is_climb() and Input.get_axis("move_up", "move_down"):
				decelerate(2)
				current_state = STATE.CLIMBING
		STATE.FALLING: ## NOTE : REVISADO SIN ERRORES
			print("State: Falling")
			
			gravity_multiplier = 1
			
			## ESTADOS
			# Climbing
			if is_climb() and Input.get_axis("move_up", "move_down"):
				decelerate(2)
				current_state = STATE.CLIMBING
			# Walking
			elif Input.get_axis("move_left", "move_right"):
				current_state = STATE.WALKING
			# Idle
			elif is_on_floor():
				decelerate(2)
				current_state = STATE.IDLE
			# Jumping - NOTE, no se puede pasar a este estado.
		STATE.CLIMBING: ## NOTE : REVISADO SIN ERRORES
			print("State: Climbing")
			
			gravity_multiplier = 0
			
			## FUNCIÓN
			# Subir, Bajar, Esperar
			if is_climb() and Input.is_action_pressed("move_up"):
				velocity.y = -gravity * delta * 5.0
			elif is_climb() and Input.is_action_pressed("move_down"):
				velocity.y = gravity * delta * 5.0
			elif is_climb():
				velocity.y = 0
			
			# Animar si se queda quieto en escalera.
			if velocity.x == 0:
				animator.play("idle")
			
			## ESTADOS
			# Walking
			if Input.get_axis("move_left", "move_right"):
				# TODO : Funciona, pero intentar refactorizar
				if is_climb():
					velocity.x = Input.get_axis("move_left", "move_right") * SPEED * delta
					decelerate(2)
				else:
					current_state = STATE.WALKING
			# Idle
			elif is_on_floor():
				current_state = STATE.IDLE
			# Falling
			elif not is_climb():
				current_state = STATE.FALLING
		STATE.HURT:  ## NOTE : REVISADO SIN ERRORES
			## FUNCION
			print("State : Hurt")
			
			# APLICAR gravedad normal.
			gravity_multiplier = 1
			# ANIMAR el daño.
			animator.play("hurt")
			
			## ESTADOS
			#Idle
			if velocity.y == 0:
				set_process_input(true)
				current_state = STATE.IDLE
			else:
				# DESACTIVAR orientación si se está moviendo verticalmente.
				set_process_input(false)
		STATE.DEATH:
			## FUNCIÓN
			
			# REDUCIR gravedad y desaceleración para mayor impulso.
			gravity_multiplier = 0.5
			decelerate(0.05)
			
			# ANIMAR según si se encuentra en el suelo o aire.
			if is_on_floor():
				animator.play("death")
			else:
				animator.play("hurt")
			
			## ESTADOS
			# NOTE, no se puede cambiar de estados.

	add_gravity(delta)
	move_and_slide()
#endregion

#region Player Functions
func add_gravity(delta : float) -> void:
	# PASAR si no hay multiplicador de gravedad.
	if gravity_multiplier == 0 : return
	# PASAR si se encuentra en el piso.
	if not is_on_floor():
		velocity.y += gravity * delta * gravity_multiplier

func decelerate(multiplier : float) -> void:
	while abs(velocity.x) > 0:
		velocity.x = move_toward(velocity.x, 0, 2.5 * multiplier)
		if is_inside_tree():
			await get_tree().process_frame  # Espera un frame antes de seguir

func hurt(hit_direction) -> void:
	# VOLVER si el jugador ya está en estado DEATH.
	if current_state == STATE.DEATH : return
	
	# OTORGAR impulso parabólico.
	velocity.x = HURT_VELOCITY * hit_direction
	velocity.y = JUMP_VELOCITY
	# CAMBIAR el estado actual del Player.
	current_state = STATE.HURT
	# REPRODUCIR sonido.
	audio_player.stream = hurt_sound
	audio_player.play()
	# EMITIR señal de que ha sido golpeado.
	on_hurt.emit()

func death() -> void:	
	# DESACTIVAR la orientación del Sprite.
	set_process_input(false)
	# CONFIGURAR y REPRODUCIR audio de muerte.
	audio_player.stream = death_sound
	audio_player.play()
	# CAMBIAR el estado actual a muerto.
	current_state = STATE.DEATH
	# REINICIAR cuando termine el audio.
	await audio_player.finished
	# TODO : En lugar de reiniciar, cambiar de escena.
	get_tree().reload_current_scene()

#endregion

#region Get & Set
func is_climb():
	return can_climb

func set_climb(value:bool):
	can_climb = value
#endregion
