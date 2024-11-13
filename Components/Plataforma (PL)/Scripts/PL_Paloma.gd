extends CharacterBody2D

const SPEED = 120.0 * 60
const JUMP_VELOCITY = -300.0

var can_mount : bool = false
var is_mount : bool = false
var player : Node2D
var paloma_state : STATE = STATE.IDLE
var gravity_multiplier : float = 1.0

# TEST
var animator : AnimatedSprite2D

enum STATE{
	IDLE,
	WALK,
	JUMP,
	IDLE_FLY,
	FLY
}

func _ready() -> void:
	# INICIALIZAR
	player = get_tree().get_first_node_in_group("Player")
	# TEST
	animator = get_node("Animated_Sprite_Paloma")

func _process(_delta: float) -> void:
	# LÓGICA para montar a paloma.
	if can_mount and Input.is_action_just_pressed("interact") and not is_mount:
		# DESACTIVAR físicas del jugador.
		player.set_physics_process(false)
		# COLOCAR pollo sobre la paloma.
		is_mount = true
		#TEST Posicionar sobre lomo.
		var new_position = self.global_position + Vector2(0, -20)
		player.global_position = new_position
		
		# TEST
		animator.play("fly")
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		animator.flip_h = true if direction == -1 else false

func _physics_process(delta: float) -> void:
	# NOTE : No hace falta procesar físicas si no se está montado.
	if not is_mount : return
	
	match paloma_state:
		STATE.IDLE:
			print("PALOMA: Idle")
			## FUNCIÓN
			gravity_multiplier = 1.0
			velocity.x = 0
			
			## ESTADOS
			# Walk
			if Input.get_axis("move_left", "move_right"):
				paloma_state = STATE.WALK
			# Jump
			elif Input.is_action_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				paloma_state = STATE.JUMP
		STATE.WALK:
			print("PALOMA: Walk")
			## FUNCIÓN
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = SPEED * direction * delta
			else:
				velocity.x = move_toward(velocity.x, 0, 10.0)
			
			## ESTADOS
			# Idle
			if is_on_floor() and velocity.x == 0:
				paloma_state = STATE.IDLE
			# Jump
			elif is_on_floor() and Input.is_action_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				paloma_state = STATE.JUMP
		STATE.JUMP:
			print("PALOMA: Jump")
			## FUNCION
			gravity_multiplier = 1.0
			
			## ESTADOS
			# Idle
			if is_on_floor() and velocity.x == 0:
				paloma_state = STATE.IDLE
			# Walk
			elif Input.get_axis("move_left", "move_right"):
				paloma_state = STATE.WALK
			# NOTE: Solo de esta forma se accede al modo vuelo.
			elif not is_on_floor() and Input.is_action_just_pressed("jump"):
				velocity.y = 0
				paloma_state = STATE.IDLE_FLY
		STATE.IDLE_FLY:
			print("PALOMA: Idle_Fly")
			## FUNCION
			gravity_multiplier = 0.025
			
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = SPEED * direction * delta
			else:
				velocity.x = move_toward(velocity.x, 0, 10.0)
			
			## ESTADOS
			# Idle
			if is_on_floor():
				paloma_state = STATE.IDLE
			# Fly
			elif Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				paloma_state = STATE.FLY
		STATE.FLY:
			print("PALOMA: Fly")
			## FUNCIÓN
			gravity_multiplier = 2.0
			
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = SPEED * direction * delta
			else:
				velocity.x = move_toward(velocity.x, 0, 10.0)
			
			## ESTADOS
			# Idle-Fly
			if velocity.y > 0:
				paloma_state = STATE.IDLE_FLY
	
	# AGREGAR gravedad.
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	move_and_slide()

func _on_talk_box_body_entered(body: Node2D) -> void:
	if body is PlatformPlayer:
		can_mount = true

func _on_talk_box_body_exited(body: Node2D) -> void:
	if body is PlatformPlayer:
		can_mount = false
