extends SuperState
@export var low_health_threshold := 40

func physics_update(delta):
	super.physics_update(delta)

	if enemy.health <= low_health_threshold:
		state_machine.transition_to("Scared", "LowHealth")
		return

	if enemy.player == null:
		state_machine.transition_to("Passive", "PlayerLost")
