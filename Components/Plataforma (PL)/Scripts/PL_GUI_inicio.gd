extends Control

# AL PRESIONAR Iniciar.
var bar_scene : PackedScene = load("res://Scenes/PL_GUI_Bar_Progress.tscn")
var first_scene = "res://Scenes/PL_Scene_LVL01.tscn"

func _on_iniciar_pressed() -> void:
	# CAMBIAR escena.
	if is_inside_tree():
		LoadScreen.change_and_prepare_scene(bar_scene, first_scene)
		
func _on_niveles_pressed() -> void:
	pass # Replace with function body.

func _on_extras_pressed() -> void:
	pass # Replace with function body.
