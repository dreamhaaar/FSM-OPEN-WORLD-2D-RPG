extends SuperState
@export var recovery_threshold := 60

func physics_update(delta):
	super.physics_update(delta)

	# stay scared until recovered
	if enemy.health < recovery_threshold:
		return

	# recovered now
	if enemy.player != null:
		state_machine.transition_to("Aggressive", "Recovered+PlayerSeen")
	else:
		state_machine.transition_to("Passive", "Recovered+PlayerLost")
