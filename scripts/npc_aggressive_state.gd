extends State

func update(delta):
	# RULE: If player is gone, go back to Passive
	if enemy.player == null:
		state_machine.transition_to("Passive")
		enemy.movement_sm.transition_to("Idle")
		return

	# RULE: If health is low, get Scared
	if enemy.health < 30:
		enemy.movement_sm.transition_to("Flee")
		state_machine.transition_to("Scared")
