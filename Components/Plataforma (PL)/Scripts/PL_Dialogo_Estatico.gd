extends Area2D

var can_talk : bool = false

@export_multiline var message = "<Sin Mensaje Configurado>"
@export var texture2D : Texture2D
@export var flip_h : bool = false

signal show_dialog(message : String)
signal hide_dialog

func _ready() -> void:
	## INICIALIZAR
	if texture2D:
		# OBTENER altura del Sprite asignado; además de Collider y Sprites2D del NPC.
		var texture_height = float(texture2D.get_height())
		var sprite : Sprite2D = get_node("NPC_Sprite")
		var marker : Sprite2D = get_node("NPC_Marker")
		var collision : CollisionShape2D = get_node("NPC_Colision")
		# CONFIGURAR nuevos parámetros (Tamaños, Posiciones)
		sprite.texture = texture2D
		sprite.global_position.y = self.position.y - texture_height/2
		collision.shape.radius = texture_height/2
		collision.global_position.y = self.position.y - texture_height/2
		marker.position = sprite.position
		marker.translate(Vector2(0, -(texture_height/2 + 10)))
		sprite.flip_h = flip_h
	
	## SEÑALES
	var gui_dialogo = get_tree().get_first_node_in_group("GUI_Dialog")
	connect("show_dialog", Callable(gui_dialogo, "process_dialog"))
	connect("hide_dialog", Callable(gui_dialogo, "hide_dialog"))

func _on_body_entered(body: Node2D) -> void:
	if body is PlatformPlayer:
		$NPC_Marker.visible = true
		can_talk = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlatformPlayer:
		# OCULTAR si no se colisiona con el área de 'habla'
		$NPC_Marker.visible = false
		can_talk = false
		hide_dialog.emit()

func _input(_event: InputEvent) -> void:
	if not can_talk : return
	
	if Input.is_action_just_pressed("interact"):
		show_dialog.emit(message)
