extends SuperState

func update(delta):
	super.update(delta)

	if enemy.health <= enemy.low_health_threshold:
		state_machine.transition_to("Scared", "LowHealth")
		return

	if enemy.player == null:
		state_machine.transition_to("Passive", "PlayerLost")
