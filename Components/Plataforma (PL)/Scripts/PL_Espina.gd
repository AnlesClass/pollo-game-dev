extends Area2D

class_name SpikePlatform

const SPIKE = preload("res://Sprites/PL_Espina.png")
const SPIKE_SIZE : float = 16.0 # Por lado.
const COLLIDER_SIZE : float = 6.0 # En Ancho.

@export var width : int = 1

func _ready() -> void:
	# MODIFICAR proporciones del collider.
	var collider : CollisionShape2D = get_node("Colision_Espina")
	collider.shape = collider.shape.duplicate()
	# CONFIGURAR valores iniciales del collider.
	collider.position.x = 0
	collider.shape.size.x = COLLIDER_SIZE
	
	# CREAR espinas
	var counter = 1
	while counter < width:
		var spike_instance = Sprite2D.new()
		spike_instance.texture = SPIKE
		spike_instance.position.x = 16 * counter
		spike_instance.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(spike_instance)
		counter += 1
	
	# CONFIGURAR nuevos valores del collider.
	if counter == 1 : return
	collider.shape.size.x += SPIKE_SIZE * (counter - 1)
	collider.position.x += SPIKE_SIZE/2 * (counter - 1)
 
func _on_body_entered(body: Node2D) -> void:
	if body is PlatformPlayer:
		# OBTENER dirección de golep aleatoria.
		var direction = randf_range(-1.5, 1.5)
		body.hurt(direction)

# NOTE: En este caso no usamos una señal, porque la espina solo sirve con el jugador
# no es reutilizable para otros enemigos y, de ser así, es menos eficiente.
# hit.emit(direction)
