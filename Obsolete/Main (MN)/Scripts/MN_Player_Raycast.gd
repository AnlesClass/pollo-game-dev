extends RayCast2D

func _ready():
	var player = get_parent()
	player.connect("orient_raycast", on_change_direction)

func on_change_direction(direction_pressed : Vector2):
	target_position = direction_pressed * 50
	# TEST : Cambiar la orientación del debug.
	var line : Line2D = $"../Debug_Line"
	line.points[1] = direction_pressed * 50
