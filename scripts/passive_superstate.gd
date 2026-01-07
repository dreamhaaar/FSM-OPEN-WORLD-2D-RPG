# Inherit from SuperState so we can run a Sub-Machine (Idle/Wander)
extends SuperState

func physics_update(delta):
	
	# UPDATE THE GAMES PHYSICS AND MOVEMENT
	super.physics_update(delta)
	
	# TRANSITION TO AGGRESSIVE IF PLAYER IS IN RANGE
	# transition_to(target state, input/trigger)
	if enemy.player != null:
		state_machine.transition_to("Aggressive", "PlayerDetected")
