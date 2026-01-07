extends Node

const scene_world1 = preload("res://scenes/World1.tscn")
const scene_world2 = preload("res://scenes/World2.tscn")

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"World1":
			scene_to_load = scene_world1
		"World2":
			scene_to_load = scene_world2
	
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)
