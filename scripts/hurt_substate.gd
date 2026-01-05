# hurt_substate.gd
extends State

@export var stun_duration: float = 0.5

func enter():
	enemy.velocity = Vector2.ZERO

	#if u add a take damage at every hit it will interfere with the states (animation has time to compelte)
	#if enemy.anim:
		#enemy.anim.play("hurt")
	

	await get_tree().create_timer(stun_duration).timeout
	
	_return_to_previous_state()

func physics_update(_delta):
	enemy.velocity = Vector2.ZERO


func _return_to_previous_state():
	if enemy.health <= enemy.low_health_threshold:
		state_machine.transition_to("Scared")
		return

	var prev = state_machine.previous_state_name
	
	if prev == "" or prev.to_lower() == "hurt":
		state_machine.transition_to("Passive")
	else:
		state_machine.transition_to(prev)
