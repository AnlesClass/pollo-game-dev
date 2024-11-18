extends Area2D

@export_file('*.tscn') var new_scene
var load_bar_scene = load("res://Scenes/PL_GUI_Bar_Progress.tscn")

var can_change_scene : bool = false

func _ready() -> void:
	# CONECTAR señales.
	self.connect("body_entered", on_body_entered)
	self.connect("body_exited", on_body_exited)

func _input(_event: InputEvent) -> void:
	# REGRESAR si no hay escena cargada.
	if not new_scene : return
	# CAMBIAR de escena si se pulsa el botón y se encuentra en el área especificada.
	if can_change_scene and Input.is_action_just_released("interact"):
		LoadScreen.call_deferred("change_and_prepare_scene", load_bar_scene, new_scene)

# SEÑAL: Cuando el jugador entra.
func on_body_entered(body : Node2D) -> void:
	if body is PlatformPlayer:
		can_change_scene = true

# SEÑAL: Cuando el jugador sale.
func on_body_exited(body: Node2D) -> void:
	if body is PlatformPlayer:
		can_change_scene = false
