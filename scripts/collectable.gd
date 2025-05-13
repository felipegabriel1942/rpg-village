extends CharacterBody2D

signal on_player_colliding(is_colliding)

var player_in_area = false
var is_chatting = false

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_event)

func _process(delta):
	if player_in_area:
		if Input.is_action_pressed("speak"):
			_run_dialogue("luceroTheCat")

func _run_dialogue(dialogue):
	if !is_chatting:
		is_chatting = true
		on_player_colliding.emit(false)
		
		Dialogic.start(dialogue)

func _on_dialogic_event(argument: String): 		
	on_player_colliding.emit(true)
	
	if argument == "lucero_the_cat_picked":
		queue_free()
		
	await get_tree().create_timer(0.5).timeout
	is_chatting = false

func _on_interactable_area_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		on_player_colliding.emit(player_in_area)

func _on_interactable_area_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		on_player_colliding.emit(player_in_area)
