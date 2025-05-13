extends PathFollow2D

signal on_player_colliding(is_colliding)

@export var speed := 40
@export var wait_time := 2.0

@onready var sprite = $NPC/AnimatedSprite2D
@onready var interactable_area = $NPC/InteractableArea

var direction := 1
var is_waiting = false
var last_position := Vector2.ZERO
var player_in_area = false
var is_chatting = false
var is_quest_accepted = false

func _ready():
	rotates = false
	loop = false
	interactable_area.body_entered.connect(_on_front_sensor_body_entered)
	interactable_area.body_exited.connect(_on_front_sensor_body_exited)
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
		on_player_colliding.emit(false)
		
		_look_at_player()
		
		Dialogic.start(dialogue)
		
func _look_at_player():
	var player = get_tree().get_nodes_in_group("Player")[0]
	var direction = player.global_position - global_position

	if abs(direction.x) > abs(direction.y):
		play_animation("side_walk")
		sprite.flip_h = direction.x < 0
	else:
		if direction.y > 0:
			play_animation("front_walk")
		else:
			play_animation("back_walk")
	
	sprite.frame = 1

func _on_dialogic_event(argument: String): 
	if argument.begins_with("start_quest_"):
		var quest_id = argument.replace("start_quest_", "")
		
		QuestManager.add_quest(quest_id, {})
	
	elif argument.begins_with("completed_quest_"):
		print("Quest Completada!!!")
		
	on_player_colliding.emit(true)
		
	await get_tree().create_timer(0.5).timeout
	
	is_chatting = false
	

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
		sprite.frame = 1

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
