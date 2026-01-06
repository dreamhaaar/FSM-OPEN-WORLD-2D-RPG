extends Control

# Signal to tell the Main Menu or Scene Manager we are done
signal finished

func _ready() -> void:
	# 1. Start the animation immediately
	# Make sure "intro_fade" exists in your AnimationPlayer!
	if $AnimationPlayer.has_animation("intro_fade"):
		$AnimationPlayer.play("intro_fade")
		
		# 2. Wait for it to finish
		await $AnimationPlayer.animation_finished
		
		# 3. Transition
		_finish_intro()
	else:
		_finish_intro()

func _unhandled_input(event):
	# Allow skipping with Space, Enter, or Mouse Click
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		_finish_intro()

func _finish_intro():
	# Prevent double-calling if the player mashes the skip button
	if is_queued_for_deletion():
		return

	# Tell the parent scene to change to the Main Menu
	finished.emit()
	
	# Destroy the intro node
	queue_free()
