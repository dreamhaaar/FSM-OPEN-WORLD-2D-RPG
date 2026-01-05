extends SuperState

@export var low_health_threshold := 30

func enter():
	print("[HFSM] Player Detected -> Aggressive")
	super.enter()  

func update(delta: float):

	super.update(delta)

	
	if enemy.player == null:
		state_machine.transition_to("Passive")
		return

	
	if enemy.health < low_health_threshold:
		state_machine.transition_to("Scared")
		return
