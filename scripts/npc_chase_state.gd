extends State

func physics_update(_delta):
	if enemy.player:
		# 1. Check Distance
		var dist = enemy.global_position.distance_to(enemy.player.global_position)
		
		if dist < 50: 
			state_machine.transition_to("Attack")
			return 

		# 2. Move towards player
		var direction = (enemy.player.global_position - enemy.global_position).normalized()
		enemy.velocity = direction * enemy.speed
		
		# 3. Determine the "Ideal" animation name based on direction
		var target_anim = "walk" # Generic fallback
		var directional_anim = ""
		
		if abs(direction.x) > abs(direction.y):
			directional_anim = "side_walk"
		else:
			directional_anim = "front_walk" if direction.y > 0 else "back_walk"
		
		# 4. SAFETY CHECK: Use the directional version if it exists, otherwise use 'walk'
		if enemy.anim.sprite_frames.has_animation(directional_anim):
			enemy.anim.play(directional_anim)
		else:
			enemy.anim.play("walk") # Fallback for Demon and simpler minions

		# 5. Handle Horizontal Flipping
		# This ensures the character faces the player regardless of the animation used
		if direction.x != 0:
			enemy.anim.flip_h = direction.x < 0
	
	else:
		state_machine.transition_to("Idle")
