# Inherit from SuperState so we can run a Sub-Machine (Chase/Attack)
extends SuperState

# This function runs every frame (triggered by the FiniteStateMachine)
func update(delta):
	# UPDATE THE GAMES PHYSICS AND MOVEMENT
	super.update(delta)

	# TRANSIION TO THE SCARED IF HEALTH IS BELOW THE THRESHOLD
	# transition_to(target state, input/trigger)
	if enemy.health <= enemy.low_health_threshold:
		state_machine.transition_to("Scared", "LowHealth")
		return
	
	# PLAYER NOT IN RANGE ANYMORE
	if enemy.player == null:
		state_machine.transition_to("Passive", "PlayerLost")
