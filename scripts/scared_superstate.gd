# Inherit from SuperState so we can run a Sub-Machine (Idle/Wander)
extends SuperState
@export var recovery_threshold := 60

func physics_update(delta):
	# UPDATE THE GAMES PHYSICS AND MOVEMENT
	super.physics_update(delta)

	# stay scared until recovered
	if enemy.health < recovery_threshold:
		return

	# noc recovered then
	# player in range
	if enemy.player != null:
		state_machine.transition_to("Aggressive", "Recovered+PlayerSeen")
	#player not in range
	else:
		state_machine.transition_to("Passive", "Recovered+PlayerLost")
