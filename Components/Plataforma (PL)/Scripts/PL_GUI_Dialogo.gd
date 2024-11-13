extends CanvasLayer

class_name GUI_Dialog

var fix_bucle : bool = false # Gestiona el reinicio del Dialog en caso de apertura y cierre constante.
var panel_dialog : Panel
var label_text : Label
var sprite_text : Sprite2D
var current_dialog_state : DIALOG_STATE = DIALOG_STATE.HIDE

@export var dialog_speed : float = 1

enum DIALOG_STATE{
	HIDE,
	DRAWING,
	SHOW
}

func _init() -> void:
	# AÑADIR al grupo
	add_to_group("GUI_Dialog")

func _ready() -> void:
	# REFERENCIAR a todos los nodos necesarios.
	panel_dialog = get_node("Panel_Dialogo")
	label_text = get_node("Panel_Dialogo/Label_Content")
	sprite_text = get_node("Panel_Dialogo/Sprite_Content")
	# CONFIGURAR valores de nodos de dialogo.
	panel_dialog.scale.x = 0.0
	label_text.visible_ratio = 0.0
	sprite_text.modulate.a = 0.0
	self.visible = true

func process_dialog(message : String):
	if current_dialog_state == DIALOG_STATE.HIDE:
		current_dialog_state = DIALOG_STATE.DRAWING
		label_text.text = message
		open_dialog()
	elif current_dialog_state == DIALOG_STATE.SHOW:
		hide_dialog()

func open_dialog():
	var t : float = 0.0
	
	while t < 1:
		t = clamp(t + 0.05, 0, 1)
		panel_dialog.scale.x = lerp(0.0, 1.0, t)
		await get_tree().process_frame
	
	show_dialog()

func show_dialog():
	var t : float = 0.0
	
	while t < 1:
		if fix_bucle:
			return
		
		t = clamp(t + dialog_speed * 0.01, 0, 1)
		label_text.visible_ratio = lerp(0.0, 1.0, t)
		sprite_text.modulate.a = t
		await get_tree().process_frame
	
	current_dialog_state = DIALOG_STATE.SHOW

func hide_dialog():
	# ASEGURAR que no se esté trabajando el método show_dialog().
	fix_bucle = true
	var t : float = panel_dialog.scale.x
	
	while t > 0:
		t = clamp(t - 0.05, 0, 1)
		panel_dialog.scale.x = lerp(0.0, 1.0, t)
		if is_inside_tree():
			await get_tree().process_frame
	
	# VOLVER a los valores iniciales.
	label_text.visible_ratio = 0
	sprite_text.modulate.a = 0
	current_dialog_state = DIALOG_STATE.HIDE
	fix_bucle = false
