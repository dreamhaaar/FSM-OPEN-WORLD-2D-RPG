# inherit and implement the state 
extends State

func physics_update(_delta):
	
	# PLAYER IS NOT WITHIN DETECTION RANGE
	if enemy.player == null:
		enemy.velocity = Vector2.ZERO
		state_machine.transition_to("Passive") 
		return

	enemy.update_facing_to_player()

	# ATTACK ON THE HITBOX
	if enemy.player_in_attack_range:
		state_machine.transition_to("Attack")
		return
	
	# Movement Logic
	var direction = (enemy.player.global_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	if distance < 35:
		enemy.velocity = Vector2.ZERO
	else:
		enemy.velocity = direction * enemy.speed
	
	enemy.move_and_slide()
	
	# walking animation plays while NPC is chasing
	if enemy.anim:
		enemy.anim.play("side_walk")
