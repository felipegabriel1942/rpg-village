extends PathFollow2D

signal on_player_colliding(is_colliding)

@export var speed := 40
@export var wait_time := 2.0

@onready var sprite = $Area2D/AnimatedSprite2D
@onready var area_2d = $Area2D

var direction := 1
var is_waiting = false
var last_position := Vector2.ZERO
var player_in_area = false
var is_chatting = false
var is_roaming = true
var is_quest_accepted = false

func _ready():
	rotates = false
	loop = false
	area_2d.body_entered.connect(_on_front_sensor_body_entered)
	area_2d.body_exited.connect(_on_front_sensor_body_exited)
	Dialogic.signal_event.connect(_on_dialogic_event)

func _process(delta):
	if player_in_area:
		if Input.is_action_pressed("speak"):
			_run_dialogue("villagerHello")	
	
	_move(delta)
	
	var movement = global_position - last_position
	
	_update_animation(movement)
	
	last_position = global_position
	
func _move(delta):
	if (!is_waiting and !player_in_area and !is_chatting):
		progress += delta * speed * direction
	
		if progress_ratio == 1:
			is_waiting = true
			await get_tree().create_timer(wait_time).timeout
			is_waiting = false
			direction = -1
		elif progress_ratio == 0:
			is_waiting = true
			await get_tree().create_timer(wait_time).timeout
			is_waiting = false
			direction = 1

func _run_dialogue(dialogue):
	if !is_chatting:
		is_chatting = true
		is_roaming = false
		on_player_colliding.emit(false)
		
		Dialogic.start(dialogue)

func _on_dialogic_event(argument: String): 
	
	if argument.begins_with("start_quest_"):
		var quest_id = argument.replace("start_quest_", "")
		
		QuestManager.add_quest(quest_id, {})
		
	await get_tree().create_timer(0.5).timeout
	
	is_chatting = false
	is_roaming = true
	on_player_colliding.emit(true)

func _update_animation(movement: Vector2):
	var x = round_to_zero(movement.x)
	var y = round_to_zero(movement.y)
	
	if (x > 0 && y == 0):
		play_animation("side_walk")
		sprite.flip_h = false
		
	elif (x < 0 && y == 0):
		play_animation("side_walk")
		sprite.flip_h = true
		
	elif (x == 0 && y > 0):
		play_animation("front_walk")
		
	elif (x == 0 && y < 0):
		play_animation("back_walk")
		
	elif (x == 0 && y == 0):
		play_animation("idle")

func play_animation(name: String):
	if sprite.animation != name:
		sprite.play(name)

func round_to_zero(value: float, epsilon: float = 0.05) -> float:
	if abs(value) < epsilon:
		return 0.0
	return value

func _on_front_sensor_body_entered(body):
	if body.name == "Player":
		on_player_colliding.emit(true)
		player_in_area = true

func _on_front_sensor_body_exited(body):
	if body.name == "Player":
		on_player_colliding.emit(false)
		player_in_area = false
