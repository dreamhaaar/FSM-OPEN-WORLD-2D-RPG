extends State

func physics_update(delta):
	if enemy.player:
		
		# Move AWAY from player
		var direction = (enemy.position - enemy.player.position).normalized()
		enemy.velocity = direction * (enemy.speed * 1.4 ) # Run faster!
		
		# Animation
		enemy.anim.play("side_walk") # Or "run" if you have it
		
		# Flip logic
		if direction.x < 0:
			enemy.anim.flip_h = true
		else:
			enemy.anim.flip_h = false


		# If we are far enough away safely, go back to Idle
		if enemy.global_position.distance_to(enemy.player.global_position) > 400:
			enemy.movement_sm.transition_to("Idle")
			
	else:
		# If player is suddenly null (e.g., player died or disconnected), stop running
		enemy.movement_sm.transition_to("Idle")
