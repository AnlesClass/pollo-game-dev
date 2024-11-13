extends Area2D

class_name PlatformLadder

## NOTE. Escalera solo funciona con jugador.

var ladder_collider : CollisionShape2D
var ladder_top_collider : CollisionShape2D

@export var width : int = 1
@export var height : int = 1

signal player_on_ladder(state : bool)

func _init() -> void:
	# AÑADIR al grupo de "Escaleras"
	add_to_group("Ladder")

func _ready():
	# REFERENCIAR / INICIALIZAR
	ladder_collider = get_node("Escalera_Collider")
	ladder_top_collider = get_node("Escalera_Top/Escalera_Top_Collider")
	
	# CONFIGURAR ANCHO * ALTO DEL COLLIDER
	scale.x = width
	scale.y = height
	
	## SEÑALES
	var player = get_tree().get_first_node_in_group("Player")
	connect("player_on_ladder", Callable(player, "set_climb"))

func _input(_event):
	# HABILITAR y DESHABILITAR el colisionador de mi escalera.
	ladder_top_collider.disabled = true if Input.is_action_pressed("move_down") else false

func _on_body_entered(body):
	# VERIFICAR si ha entrado el jugador en la zona.
	if body is PlatformPlayer:
		player_on_ladder.emit(true)

func _on_body_exited(body):
	# DESANCLAR el jugador de la zona-
	if body is PlatformPlayer:
		player_on_ladder.emit(false)
