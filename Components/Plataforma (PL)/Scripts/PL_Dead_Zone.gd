extends Area2D

@export var area_size : Vector2 = Vector2(40,40)

signal on_player_entered

func _ready() -> void:
	## SEÑALES
	var player = get_tree().get_first_node_in_group("Player")
	connect("on_player_entered", Callable(player, "death"))

func _on_body_entered(body: Node2D) -> void:
	if body is PlatformPlayer:
		on_player_entered.emit()
