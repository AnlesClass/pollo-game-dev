extends Path2D

class_name PlatformMovil

var node_parent : Node2D
var path_follow : PathFollow2D
var direction = 1

@export var desplazamiento : Vector2
@export var wait_time : float = 1.0
@export var speed : float = 1.0

func _ready() -> void:
	# REFERENCIAS
	path_follow = get_node("Seguidor_Ruta")
	# INICIALIZAR
	path_follow.progress_ratio = 0.0
	if desplazamiento:
		# NOTE: Duplicamos la curva porque cuando está en una escena como esta se vuelve
		# un recursos compartido. Es decir, si modificamos una modificamos todas.
		curve = self.curve.duplicate()
		curve.set_point_position(1, desplazamiento)

func _process(delta: float) -> void:
	# DESPLAZAR plataforma
	path_follow.progress_ratio += direction * speed * delta
	
	# INVERTIR dirección y ESPERAR N segundos.
	if path_follow.progress_ratio == 1 or path_follow.progress_ratio == 0:
		invert(wait_time)

func invert(seconds : float) -> void:
	set_process(false)
	await get_tree().create_timer(seconds).timeout
	direction *= -1
	set_process(true)


func _on_area_plataforma_body_entered(body: Node2D) -> void:
	# EJECUTAR si es un nodo de jugador y su padre NO es un PathFollow2D.
	if body is PlatformPlayer and body.get_parent() is not PathFollow2D:
		print("Entre a Plataforma")
		# GUARDAR posición GLOBAL para usarlo más adelante.
		var body_global_position = body.global_position
		# OBTENER una referencia al nodo padre actual.
		node_parent = body.get_parent()
		# SACAR al nodo de su contenedor actual.
		node_parent.remove_child(body)
		# EJECUTAR de manera diferida el añadido del nodo a ESTA escena.
		call_deferred("add_child_deferred", path_follow, body, body_global_position)

func _on_area_plataforma_body_exited(body: Node2D) -> void:
	# EJECUTAR si es un nodo de jugador y su padre ES un PathFollow2D.
	if body is PlatformPlayer and body.get_parent() is PathFollow2D:
		print("Sali de Plataforma")
		# GUARDAR posición GLOBAL para usarlo más adelante.
		var body_global_position = body.global_position
		# REMOVEMOS el hijo de nuestro pathfollow
		path_follow.call_deferred("remove_child", body)
		# EJECUTAMOS de manera diferida un add_child para devolverlo a la escena
		# que era su padre original.
		call_deferred("add_child_deferred", node_parent, body, body_global_position)

func add_child_deferred(parent : Node2D, child : Node2D, globalposition : Vector2):
	# AGREGAR el child al nuevo parent (Agrupar)
	parent.add_child(child)
	# CONFIGURAR la posición global del child a la misma que tenía antes de salir.
	child.global_position = globalposition
