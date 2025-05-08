extends CharacterBody2D

class_name Player

@export var speed: float = 100.0

@onready var animated_sprite = $AnimatedSprite2D

var is_chatting = false

func _physics_process(delta):
	is_chatting = Dialogic.VAR.is_chatting
	
	_move(delta)
	
func _move(delta):	
	if !is_chatting:
		var direction = _get_input_direction()
		
		_play_move_animation(direction)
		
		velocity = direction * speed

		move_and_slide()

func _play_move_animation(direction) -> void:
	if direction == Vector2.UP:
		animated_sprite.play("back_walk")
	elif direction == Vector2.LEFT:
		animated_sprite.flip_h = true
		animated_sprite.play("side_walk")
	elif direction == Vector2.DOWN:
		animated_sprite.play("front_walk")
	elif direction == Vector2.RIGHT:
		animated_sprite.flip_h = false
		animated_sprite.play("side_walk")
	else:
		animated_sprite.play("idle")

func _get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	direction.y -= Input.get_action_strength("move_up")
	direction.y += Input.get_action_strength("move_down")
	direction.x -= Input.get_action_strength("move_left")
	direction.x += Input.get_action_strength("move_right")
	return direction.normalized()
