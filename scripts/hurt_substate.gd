extends State

@export var stun_duration: float = 0.5

func enter():
	enemy.velocity = Vector2.ZERO

	await get_tree().create_timer(stun_duration).timeout
	_return_to_previous_state()

func physics_update(_delta):
	enemy.velocity = Vector2.ZERO

func _return_to_previous_state():
	# 0) If enemy is dead, always go Death (terminal)
	if enemy.health <= 0:
		state_machine.transition_to("Death", "Health=0")
		return

	# 1) If low health, go Scared immediately after Hurt ends
	# (This prevents the brief return to Aggressive you saw in the logs.)
	if enemy.health <= enemy.low_health_threshold:
		state_machine.transition_to("Scared", "LowHealthAfterHurt")
		return

	# 2) Otherwise return to previous superstate (history)
	var prev := state_machine.previous_state_name

	# Safety fallback
	if prev == "" or prev.to_lower() == "hurt":
		state_machine.transition_to("Passive", "HurtEndFallback")
		return

	state_machine.transition_to(prev, "HurtEnd")
