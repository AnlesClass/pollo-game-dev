extends CharacterBody2D

const JUMP_VELOCITY = -200
const JUMP_TIME = 2.5
const RESPAWN_TIME = 3.0
const SPEED = 120.0 * 60 # Multipicador por usar delta.

var animated_sprite : AnimatedSprite2D
var current_state : STATE = STATE.IDLE
var direction  : int = 1
var hit_box : CollisionShape2D

enum STATE{
	IDLE, # Solo cuando cae, velocidad.x = 0
	CHARGING, # El tiempo esperando en el suelo antes del salto
	JUMPING # El tiempo en el aire.
}

signal hit(direction : int)

func _ready() -> void:
	## SEÑALES
	var player = get_tree().get_first_node_in_group("Player")
	connect("hit", Callable(player, "hurt"))
	## REFERENCIAS
	hit_box = get_node("Hit_Box/Collision_Hit_Box")
	animated_sprite = get_node("Animated_Sprite_Enemy_Frog")
	## CONFIGURACIÓN
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	match current_state:
		STATE.IDLE:
			## ESTADOS
			# Charging
			if is_on_floor():
				animated_sprite.play("idle")
				charge_jump()
		STATE.CHARGING:
			## FUNCIÓN
			velocity.x = 0
		STATE.JUMPING:
			## FUNCIÓN

			# APLICAR velocidad vertical.
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
				
			## ESTADOS
			# Idle
			if velocity.y > 0:
				current_state = STATE.IDLE
	
	# CAMBIAR dirección de movimiento.
	if is_on_wall():
		var normal = get_wall_normal()
		direction = normal.x


	# APLICAR velocidad horizontal.
	if not is_on_floor():
		animated_sprite.play("jump")
		velocity.x = SPEED * direction * delta
	
	# MANEJAR gravedad.
	velocity += get_gravity() * delta
	
	# ACTUALIZAR animación.
	animated_sprite.flip_h = false if direction == 1 else true 
	
	move_and_slide()

func charge_jump():
	## TRANSICIONAR : Estado Charging...
	current_state = STATE.CHARGING
	await get_tree().create_timer(1.5).timeout # Tiempo de carga del salto.
	## TRANSICIONAR : Estado Jumping...
	current_state = STATE.JUMPING

func _on_hit_box_body_entered(body: Node2D) -> void:
	# OBTENER dirección del golpe.
	var hit_direction = clamp(body.global_position.x - self.global_position.x, -1, 1)
	# EMITIR señal del golpe.
	hit.emit(hit_direction)
	# DESACTIVAR colisión y transparentar al enemigo.
	animated_sprite.modulate.a = 0.5
	hit_box.call_deferred("set_disabled", true)
	await get_tree().create_timer(RESPAWN_TIME).timeout
	# ACTIVAR colisión y transparentar al enemigo.
	animated_sprite.modulate.a = 1
	hit_box.call_deferred("set_disabled", false)
