# hurt_substate.gd
extends State

@export var stun_duration: float = 0.5

func enter():
	enemy.velocity = Vector2.ZERO

	# Optional: play hurt anim here if you want
	# if enemy.anim:
	#     enemy.anim.play("hurt")

	await get_tree().create_timer(stun_duration).timeout
	_return_to_previous_state()

func physics_update(_delta):
	enemy.velocity = Vector2.ZERO

func _return_to_previous_state():
	# Return to previous HFSM superstate (stored by the FSM)
	var prev := state_machine.previous_state_name

	# Safety fallback
	if prev == "" or prev.to_lower() == "hurt":
		state_machine.transition_to("Passive", "HurtEndFallback")
		return

	state_machine.transition_to(prev, "HurtEnd")
