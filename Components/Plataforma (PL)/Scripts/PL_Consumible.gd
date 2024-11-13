extends Area2D

signal healing
 
func _init() -> void:
	# AGREGAR a un grupo
	add_to_group("Consumable")

func _ready() -> void:
	## SEÑALES
	# Cuando un cuerpo entra.
	self.connect("body_entered", on_body_entered)
	# Cuando se toma el objeto curable.
	var gui_health = get_tree().get_first_node_in_group("GUI_Health")
	connect("healing", Callable(gui_health, "on_get_health"))

func on_body_entered(body : Node2D):
	if body is PlatformPlayer:
		healing.emit()
		queue_free()
