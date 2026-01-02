extends State

func enter():
	enemy.velocity = Vector2.ZERO 
	
	if not enemy.player:
		state_machine.transition_to("Idle")
		return

	# 1. INITIAL ANIMATION SELECTION
	var direction = (enemy.player.global_position - enemy.global_position).normalized()
	var directional_anim = ""
	
	if abs(direction.x) > abs(direction.y):
		directional_anim = "side_attack"
	else:
		directional_anim = "front_attack" if direction.y > 0 else "back_attack"

	# Play the best available animation
	if enemy.anim.sprite_frames.has_animation(directional_anim):
		enemy.anim.play(directional_anim)
	else:
		enemy.anim.play("attack") 
	
	# 2. WAIT FOR IMPACT
	await get_tree().create_timer(0.5).timeout
	
	# 3. DEAL DAMAGE
	if enemy.player and enemy.global_position.distance_to(enemy.player.global_position) < 60:
		if enemy.player.has_method("take_damage"):
			enemy.player.take_damage(10)

	# 4. RECOVERY PHASE
	await get_tree().create_timer(1.0).timeout 
	enemy.movement_sm.transition_to("Chase")

func physics_update(_delta):
	# STOP MOVEMENT
	enemy.velocity = Vector2.ZERO
	
	# 5. ALWAYS FACE THE PLAYER
	# This runs every frame, so if the player moves behind the enemy, the enemy flips instantly.
	if enemy.player:
		var direction = (enemy.player.global_position - enemy.global_position).normalized()
		if direction.x != 0:
			enemy.anim.flip_h = direction.x < 0
