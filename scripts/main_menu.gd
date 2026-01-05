extends Control

# Signal to tell the World script to unpause
signal start_game

func _ready() -> void:
	# Ensure the mouse is visible when the menu loads
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_pressed() -> void:
	print("BUTTON CLICKED! Sending signal...")
	# 1. Tell the World we are ready to play
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	start_game.emit()
	
	# 2. Destroy the menu (so the player can see the game)
	queue_free()

func _on_options_pressed() -> void:
	print("Options menu not implemented yet")
	# You would instantiate an options popup here

func _on_quit_pressed() -> void:	
	get_tree().quit()
