extends CanvasLayer

class_name GUI_Health

var hearts_container : HBoxContainer
var remaining_hearts : int = 3

@export var texture_health : Texture2D
@export var texture_without_health : Texture2D

signal death

func _init() -> void:
	# AÑADIR a grupo
	add_to_group("GUI_Health")

func _ready() -> void:
	# INICIALIZAR
	hearts_container = get_node("Container_Vida")
	
	for heart in hearts_container.get_children():
		heart.texture = texture_health
	
	## SEÑALES
	var player = get_tree().get_first_node_in_group("Player")
	# Cuando el jugador sufre daño.
	player.connect("on_hurt", on_hurt)
	# Cuando nos quedamos sin corazones.
	connect("death", Callable(player, "death"))
	

func on_hurt():
	# OBTENER corazones de su contenedor.
	var hearts = hearts_container.get_children()
	for heart : TextureRect in hearts:
		# CONVERTIR corazones llenos en vacíos.
		if heart.texture == texture_health:
			heart.texture = texture_without_health
			# DISMINUIR las vidas restantes y determinar si morimos.
			remaining_hearts -= 1
			if remaining_hearts == 0:
				break
			else:
				return 
	
	death.emit()

func on_get_health():
	# OBTENER corazones del contener e INVERTIR para obtener los últimos corazones primero.
	var hearts = hearts_container.get_children()
	hearts.reverse()
	# CONVERTIR corazones vacíos en llenos.
	for heart : TextureRect in hearts:
		# AUMENTAR +1 Corazón
		if heart.texture == texture_without_health:
			heart.texture = texture_health
			# DISMINUIR las vidas restantes y determinar si morimos.
			remaining_hearts += 1
			break
