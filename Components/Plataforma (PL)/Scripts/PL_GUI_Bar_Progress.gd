extends Control

class_name BarProgressScene

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var mensaje: Label = $Mensaje

# Escena por Archivo/File.
var next_scene

func _process(delta: float) -> void:
	progress_bar.value += randf_range(0, 2)
	if progress_bar.value == 100:
		next_level()

func set_next_scene(scene):
	next_scene = scene

func next_level():
	# DESACTIVAR el procesamiento.
	set_process(false)
	# ESPERAR 1.5 segundos.
	if is_inside_tree():
		await get_tree().create_timer(1.5).timeout
	# PASAR a la siguiente escena.
	if next_scene:
		LoadScreen.change_generic_scene(next_scene)
	else:
		mensaje.text = "Sin Escena Cargada"
