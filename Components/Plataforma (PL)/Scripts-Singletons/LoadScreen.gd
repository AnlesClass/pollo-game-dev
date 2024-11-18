extends Node

func change_generic_scene(scene):
	get_tree().change_scene_to_file(scene)

func change_and_prepare_scene(bar_scene : PackedScene, scene):
	var bar_instance = bar_scene.instantiate()
	if bar_instance is BarProgressScene:
		bar_instance.set_next_scene(scene)
		get_tree().root.add_child(bar_instance)
		get_tree().current_scene.queue_free()
	else:
		print("La escena que se quiere cargar no es un 'BarProgressScene'.")
