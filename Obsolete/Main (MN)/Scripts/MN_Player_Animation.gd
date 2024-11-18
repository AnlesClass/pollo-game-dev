extends AnimatedSprite2D

# UP, DOWN, RIGHT, LEFT
var keys = ["m_up", "m_down", "m_right", "m_left"]
var look = ["look_up", "look_down", "look_right", "look_left"]
var walk = ["walk_up", "walk_down", "walk_right", "walk_left"]

func _process(delta):
	# Probablemente borrar esto
	# MIRAR según si se camina o se está parado.
	for i in range(look.size()):
		if Input.is_action_just_released(keys[i]):
			play(look[i])
			break
		if Input.is_action_pressed(keys[i]) :
			play(walk[i])
			break
