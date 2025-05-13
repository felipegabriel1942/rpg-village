extends Node2D

@export var exit: Node2D
@export_file() var next_level

@onready var hint_panel = $UILayer/HintPanel
@onready var player = $Player

var lucero_the_cat_scene = preload("res://scenes/lucero_the_cat.tscn")

func _ready():
	exit.body_entered.connect(_on_player_enter)
	Dialogic.signal_event.connect(_on_dialogic_event)
	_instantiate_lucero_the_cat()

func _on_dialogic_event(argument: String):
	if argument == "completed_quest_find_lucero_the_cat":
		Dialogic.VAR.lucero_position = "105,-159"
		_instantiate_lucero_the_cat()

func _instantiate_lucero_the_cat():
	if !(Dialogic.VAR.quest_find_lucero_the_cat_accepted == true && Dialogic.VAR.quest_find_lucero_the_cat_completed == false && Dialogic.VAR.lucero_found == true):
		var lucero_the_cat_instance = lucero_the_cat_scene.instantiate()
		lucero_the_cat_instance.add_to_group("LuceroTheCat")
		lucero_the_cat_instance.position = _get_lucero_the_cat_position()
		lucero_the_cat_instance.on_player_colliding.connect(_on_lucero_the_cat_on_player_colliding)
		add_child(lucero_the_cat_instance)

func _get_lucero_the_cat_position():
	return Vector2(Dialogic.VAR.lucero_position.split(",")[0].to_float(), Dialogic.VAR.lucero_position.split(",")[1].to_float());

func _on_player_enter(body) -> void:
	if body is Player:
		get_tree().change_scene_to_file(next_level)

func _on_npc_player_colliding(is_colliding):
	hint_panel.visible = is_colliding

func _on_lucero_the_cat_on_player_colliding(is_colliding):
	hint_panel.visible = is_colliding
