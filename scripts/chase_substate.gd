extends State

func physics_update(_delta):
	if enemy.player == null:
		enemy.velocity = Vector2.ZERO
		state_machine.transition_to("Passive") 
		return

	# 2. Facing
	enemy.update_facing_to_player()

	# 3. ATTACK TRANSITION (Only trust the Hitbox!)
	if enemy.player_in_attack_range:
		state_machine.transition_to("Attack")
		return
	
	# 4. Movement Logic
	var direction = (enemy.player.global_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	# STOP moving if we are very close, but DO NOT attack yet.
	# This fixes the "Jitter" without causing the infinite attack loop.
	# 35 is roughly the size of your collision circle + a bit of buffer.
	if distance < 35:
		enemy.velocity = Vector2.ZERO
	else:
		enemy.velocity = direction * enemy.speed
	
	enemy.move_and_slide()
	
	if enemy.anim:
		enemy.anim.play("side_walk")
