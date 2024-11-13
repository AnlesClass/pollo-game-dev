extends Area2D

class_name EventMoveCamera

@export var target_position : Vector2 = Vector2(0, 0)
@export var duration : float = 5.0
@export var interval : float = 1.0

var player : PlatformPlayer
var player_camera : Camera2D

signal tween_finished

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	player_camera = player.get_node("PL_Camera")
	self.connect("body_entered", on_body_entered)

func on_body_entered(body : Node2D):
	if body is PlatformPlayer:
		# GUARDAR posición inicial
		var origin = player_camera.global_position
		# CREAR Tween para animar cámara.
		var tween = get_tree().create_tween()
		# BLOQUEAR el movimiento del jugador.
		lock_move(true)
		player.animator.stop()
		# LLEVAR cámara a destino.
		tween.tween_property(player_camera, "global_position", target_position, duration/2).\
		set_ease(Tween.EASE_IN_OUT).\
		set_trans(Tween.TRANS_CUBIC)
		# ESPERAR 1 segundo y EJECUTAR acción (Opcional)
		tween.tween_callback(execute_action)
		tween.tween_interval(interval)
		# LLEVAR cámara al origen.
		tween.tween_property(player_camera, "global_position", origin, duration/2).\
		set_ease(Tween.EASE_IN_OUT).\
		set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(tween_complete)
		tween.tween_callback(queue_free)

func execute_action():
	print("Acción a realizar...")

func tween_complete():
	lock_move(false)
	tween_finished.emit()

func lock_move(condition : bool) -> void:
	player.set_physics_process(not condition)
	player.set_process_input(not condition)
