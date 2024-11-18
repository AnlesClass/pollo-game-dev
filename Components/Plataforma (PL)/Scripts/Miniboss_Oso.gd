extends Area2D

func execute_anim() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", self.global_position + Vector2(515, 0), 4.5)
	tween.tween_callback(anim_finished)

func anim_finished():
	var animator : AnimatedSprite2D = $Oso_Animation
	animator.play("roar")

func _on_body_entered(body: Node2D) -> void:
	## TODO: Corregir/Mejorar.
	if body is PlatformPlayer:
		var player = get_tree().get_first_node_in_group("Player")
		player.hurt(1) # Dirección desde la que le pego.
