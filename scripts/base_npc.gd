extends PathFollow2D

@export var speed := 40
@export var wait_time := 2.0

@onready var sprite = $Area2D/AnimatedSprite2D
@onready var area_2d = $Area2D

var direction := 1
var is_waiting := false
var last_position := Vector2.ZERO
var is_blocked := false

func _ready():
	rotates = false
	loop = false
	area_2d.body_entered.connect(_on_front_sensor_body_entered)
	area_2d.body_exited.connect(_on_front_sensor_body_exited)
	
func _process(delta):
	z_index = int(global_position.y)
	
	_move(delta)
	
	var movement = global_position - last_position
	
	_update_animation(movement)
	
	last_position = global_position
	
func _move(delta):
	
	if is_blocked:
		if Input.is_action_just_pressed("dialogic_default_action"):
			_run_dialogue("villagerHello")	
	
	if (!is_waiting and !is_blocked):
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
	print("estou dialogando")
	Dialogic.start(dialogue)
	print("terminei o dialogo")

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
		print("entrou")
		is_blocked = true

func _on_front_sensor_body_exited(body):
	if body.name == "Player":
		print("saiu")
		is_blocked = false
