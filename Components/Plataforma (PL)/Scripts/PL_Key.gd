extends Node2D

class_name KeyPlatform

var t : float = 0.0
var key : Area2D
var marker_target : Marker2D

@export var identifier : int = 0
@export var global_position_target : Vector2 = Vector2.ZERO

signal used_key()

func _init() -> void:
	# AGREGAR a un grupo.
	add_to_group("Key")

func _ready() -> void:
	# CANCELAR el procesamiento del Process
	set_process(false)
	# CONFIGURAR el punto global
	marker_target = get_node("Marker2D")
	marker_target.position = to_local(global_position_target)
	marker_target.rotation_degrees = 180
	# REFERENCIAR
	key = get_node("Area_Key")

func _process(delta: float) -> void:
	t = clamp(t + delta * 0.05, 0, 1)
	
	if key.global_position.distance_to(marker_target.global_position) < 0.5:
		t = 1
	
	key.transform = key.transform.interpolate_with(marker_target.transform, t)
	
	if t == 1:
		fade_out()
		set_process(false)

func _on_area_key_body_entered(body: Node2D) -> void:
	if body is PlatformPlayer:
		set_process(true)

func fade_out():
	# DECLARAR variables necesarias
	var fade_speed : float = 0.05
	var progress : float = 0
	
	while progress < 1:
		progress += fade_speed
		
		# Ajusta el canal alfa de modulate
		modulate.a = lerp(1.0, 0.0, progress)
		# Espera al siguiente frame
		if is_inside_tree():
			await get_tree().process_frame
	
	# INDICAR que se usó la llave.
	used_key.emit()
	# LIBERAR nodo.
	queue_free()
