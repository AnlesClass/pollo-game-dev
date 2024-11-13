extends EventMoveCamera
## NOTE: Esta es una sección única, este script no es reutilizable, por lo
## que se encuentra fuertemente acoplado al 'Oso'.

var oso : Area2D
var oso_animator : AnimatedSprite2D

func _ready() -> void:
	super._ready()
	## FUERTEMENTE ACOPLADO
	oso = $"../Oso"
	# REFERENCIAR al nodo de animación.
	oso_animator = oso.get_node("Oso_Animation")
	oso_animator.play("sleep")
	## SEÑALES
	super.connect("tween_finished", on_tween_finished)

func execute_action():
	# ACTIVAR el collider del oso.
	var oso_collider = oso.get_node("Oso_Collision")
	oso_collider.disabled = false
	# ANIMAR el oso despertando.
	oso_animator.play("idle")
	await oso_animator.animation_looped
	oso_animator.play("roar")
	await oso_animator.animation_looped
	oso_animator.play("idle")

func on_tween_finished():
	oso_animator.play("run")
	oso.execute_anim()
