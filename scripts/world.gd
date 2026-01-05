extends Node2D

@onready var intro = $CanvasLayer/intro_sequence

# --- 1. MENU SETUP ---
# Keep your existing menu setup
@export var main_menu_scene: PackedScene 

# --- 2. GAME SETUP (The Missing Piece) ---
# Paste the path to your actual game/level here in the Inspector
@export_file("*.tscn") var game_scene_path = "res://scenes/world.tscn"

func _ready():
	# Pause everything (Stop goblins/player from moving)
	get_tree().paused = true
	
	if intro:
		intro.finished.connect(_on_intro_finished)
	else:
		_on_intro_finished()

func _on_intro_finished():
	print("Intro done. Spawning Menu...")
	
	if main_menu_scene:
		var menu_instance = main_menu_scene.instantiate()
		$CanvasLayer.add_child(menu_instance)
		menu_instance.start_game.connect(_on_game_start)
	else:
		print("ERROR: Main Menu Scene not assigned!")
		_on_game_start()

func _on_game_start():
	print("Menu Closed. Game Starting!")
	
	# --- 3. SPAWN THE GAME WORLD ---
	if game_scene_path:
		# Load the file from the location you provided
		var level_res = load(game_scene_path)
		
		if level_res:
			var level_instance = level_res.instantiate()
			add_child(level_instance) # Spawns the Player/Map into the world
		else:
			print("Error: Could not load game level from path: ", game_scene_path)
	
	# --- 4. UNPAUSE ---
	get_tree().paused = false
