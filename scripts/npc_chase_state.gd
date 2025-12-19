extends State

func physics_update(delta):

	if enemy.player:

		# 1. Check Distance (Now safe because we know player exists)
		var dist = enemy.global_position.distance_to(enemy.player.global_position)
		
		if dist < 50: 
			state_machine.transition_to("Attack")
			return # Stop moving if we are attacking
		
		# 2. Move towards player
		var direction = (enemy.player.position - enemy.position).normalized()
		enemy.velocity = direction * enemy.speed
		
		# 3. Pick the correct animation based on direction
		var anim_name = "side_walk"
		
		if abs(direction.x) > abs(direction.y):
			# Moving Horizontally
			anim_name = "side_walk" 
			enemy.anim.flip_h = direction.x < 0 # Flip if moving left
		else:
			# Moving Vertically
			if direction.y > 0:
				anim_name = "front_walk" # Moving Down
			else:
				anim_name = "back_walk"  # Moving Up
				
		enemy.anim.play(anim_name)
	
	else:
		# If player is null, stop chasing
		state_machine.transition_to("Idle")
