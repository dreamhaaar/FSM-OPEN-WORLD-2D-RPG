extends State

func enter():
	enemy.velocity = Vector2.ZERO # Stop moving
	
	# Safety Check
	if not enemy.player:
		state_machine.transition_to("Idle")
		return

	# 1. FACE THE PLAYER & ANIMATE
	var direction = (enemy.player.global_position - enemy.global_position).normalized()
	var anim_name = "front_attack"
	
	if abs(direction.x) > abs(direction.y):
		anim_name = "side_attack"
		enemy.anim.flip_h = direction.x < 0
	else:
		if direction.y > 0: anim_name = "front_attack"
		else: anim_name = "back_attack"
				
	enemy.anim.play(anim_name)
	
	# 2. WAIT FOR IMPACT (Sync with animation swing)
	await get_tree().create_timer(0.5).timeout
	
	# 3. DEAL DAMAGE
	if enemy.player and enemy.global_position.distance_to(enemy.player.global_position) < 60:
		if enemy.player.has_method("take_damage"):
			enemy.player.take_damage(10)

	# --- NEW SECTION: RECOVERY PHASE ---
	
	# 4. Play "Idle" so they don't freeze in the attack pose
	if abs(direction.x) > abs(direction.y):
		enemy.anim.play("side_idle")
	else:
		if direction.y > 0: enemy.anim.play("front_idle")
		else: enemy.anim.play("back_idle")

	# 5. WAIT (The Interval)
	# This creates the pause between attacks (e.g., 2.0 seconds)
	await get_tree().create_timer(1.0).timeout 
	
	# 6. NOW go back to Chasing
	enemy.movement_sm.transition_to("Chase")

func physics_update(delta):
	enemy.velocity = Vector2.ZERO
