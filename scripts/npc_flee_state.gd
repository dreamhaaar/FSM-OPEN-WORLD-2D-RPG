extends State

func physics_update(delta):
	# 1. Safety Check: Do we even have a player target?
	if enemy.player:
		
		# --- MOVEMENT LOGIC ---
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

		# --- DISTANCE CHECK (Must be inside the "if enemy.player" block) ---
		# If we are far enough away safely, go back to Idle
		if enemy.global_position.distance_to(enemy.player.global_position) > 400:
			enemy.movement_sm.transition_to("Idle")
			# Optional: Reset behavior to Passive?
			# enemy.behavior_sm.transition_to("Passive")
			
	else:
		# If player is suddenly null (e.g., player died or disconnected), stop running
		enemy.movement_sm.transition_to("Idle")
