# scared_superstate.gd
class_name ScaredSuperState
extends SuperState

@export var health_recovery_threshold: int = 30 # Example value
@export var detection_range: float = 10.0

func update(delta: float):
	# 1. Run the Sub-FSM (Flee logic)
	super.update(delta) 

	# 2. Check Exits (According to Diagram)
	if enemy.health > health_recovery_threshold:
		var distance = enemy.global_position.distance_to(enemy.player.global_position)
		
		if distance <= detection_range:
			state_machine.transition_to("Aggressive")
		else:
			state_machine.transition_to("Passive")
