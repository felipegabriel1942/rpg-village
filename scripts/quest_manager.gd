extends Node

var quests = {}

func add_quest(id: String, data: Dictionary):
	quests[id] = {
		"data": data,
		"completed": false,
		"progress": 0
	}

func complete_quest(id: String):
	quests[id].completed = true
