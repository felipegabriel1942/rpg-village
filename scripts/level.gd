extends Node2D

@export var exit: Node2D
@export_file() var next_level

func _ready():
	exit.body_entered.connect(_on_player_enter)

func _process(delta):
	pass

func _on_player_enter(body) -> void:
	if body is Player:
		get_tree().change_scene_to_file(next_level)
	
