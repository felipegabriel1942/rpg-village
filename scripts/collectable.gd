extends CharacterBody2D

var player_in_area = false
var is_chatting = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if player_in_area:
		if Input.is_action_pressed("speak"):
			_run_dialogue("luceroTheCat")	

	if Dialogic.VAR.lucero_found:
		queue_free()

func _run_dialogue(dialogue):
	if !is_chatting:
		is_chatting = true
		#is_roaming = false
		#on_player_colliding.emit(false)
		
		Dialogic.start(dialogue)
	
func _on_interactable_area_body_entered(body):
	if body.name == "Player":
		player_in_area = true

func _on_interactable_area_body_exited(body):
	if body.name == "Player":
		player_in_area = false
