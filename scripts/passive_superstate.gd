extends SuperState

func physics_update(delta):
	super.physics_update(delta)
	# print("PASSIVE PHYSICS sees player:", enemy.player) <--- REMOVE OR COMMENT OUT
	
	# Only transition if we actually see them
	if enemy.player != null:
		state_machine.transition_to("Aggressive", "PlayerDetected")
