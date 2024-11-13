extends Node2D

class_name PlatformAxe

@export var speed = 1.5
@export var amplitude = 80.0 # amplitud en grados

var angle = 0.0

signal hurt(direction)

var axe : CollisionShape2D

func _ready():
	# AÑADIR al grupo 'Hacha'
	add_to_group("Axe")
	# REFERENCIAR collider del hacha
	axe = get_node("Hacha_Filo/Hacha_Filo_Collider")
	## SEÑALES
	var player = get_tree().get_first_node_in_group("Player")
	# Cuando el hacha alcanza al jugador.
	connect("hurt", Callable(player, "hurt"))

func _process(delta):
	angle += speed * delta
	rotation_degrees = sin(angle) * amplitude

func _on_hacha_filo_body_entered(body: Node2D):
	if body is PlatformPlayer:
		# Body -> Player, Axe -> Collider de Hacha
		var body_direction = clamp(body.position.x - axe.global_position.x, -1, 1)
		# La Dirección del Cuerpo indica hacia donde lo moverá el golpe!
		hurt.emit(body_direction)
		disable(3)

func disable(seconds : float):
	axe.call_deferred("set_disabled", true)
	await get_tree().create_timer(seconds).timeout
	axe.call_deferred("set_disabled", false)
