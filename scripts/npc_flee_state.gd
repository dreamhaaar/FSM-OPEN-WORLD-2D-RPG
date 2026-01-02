extends State

func physics_update(_delta):
	if enemy.player:
		# 1. Move AWAY from player
		var direction = (enemy.global_position - enemy.player.global_position).normalized()
		enemy.velocity = direction * (enemy.speed * 1.4) # Run faster!
		
		# 2. Choose Animation Name
		var target_anim = "walk" # Ultimate fallback
		var directional_walk = ""
		var run_anim = "run" # If you ever add run animations
		
		# Determine directional name
		if abs(direction.x) > abs(direction.y):
			directional_walk = "side_walk"
		else:
			directional_walk = "front_walk" if direction.y > 0 else "back_walk"

		# 3. Logic Chain: Run -> Directional Walk -> Generic Walk
		if enemy.anim.sprite_frames.has_animation(run_anim):
			enemy.anim.play(run_anim)
		elif enemy.anim.sprite_frames.has_animation(directional_walk):
			enemy.anim.play(directional_walk)
		else:
			enemy.anim.play("walk") # Fallback for Demon/simple minions

		# 4. Flip Logic
		if direction.x != 0:
			enemy.anim.flip_h = direction.x < 0

		# 5. Distance Check to stop fleeing
		if enemy.global_position.distance_to(enemy.player.global_position) > 400:
			state_machine.transition_to("Idle")
			
	else:
		state_machine.transition_to("Idle")
