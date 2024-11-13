extends StaticBody2D

@export var key_identifier : int = 0
@export var texture = preload("res://Sprites/PL_Door_001.png")

func _ready() -> void:
	# CONECTAR - Las o la llave a la puerta.
	var keys = get_tree().get_nodes_in_group("Key")
	for key : KeyPlatform in keys:
		if key_identifier == key.identifier:
			key.connect("used_key", on_used_key)
	# ASIGNAR textura a puerta.
	get_node("Sprite_Puerta_Barras").texture = texture;

func on_used_key():
	var progress : float = 0
	while true:
		progress += get_process_delta_time()
		scale.y = lerp(1.0, 0.0, progress)
		if is_inside_tree():
			await get_tree().process_frame
		else:
			return
		
		if scale.y <= 0:
			scale.y = 0
			break
	
	queue_free()
