extends State

func enter():
	# 1. Stop all movement immediately
	enemy.velocity = Vector2.ZERO
	
	# 2. Disable collisions so the player can't hit the dead body
	# (Optional but recommended)
	enemy.find_child("CollisionShape2D").set_deferred("disabled", true)
	
	# 3. Play the Death Animation
	# Note: In LPC sheets, "hurt" is often used for death. 
	# Make sure this animation is NOT set to 'Loop' in your SpriteFrames!
	enemy.anim.play("die") 
	
	# 4. Wait for the animation to finish
	# You can use the animation length, or a fixed timer (e.g., 1 second)
	await get_tree().create_timer(1).timeout
	
	# 5. NOW we delete the enemy
	enemy.queue_free()

func physics_update(delta):
	# Ensure they don't slide while dying
	enemy.velocity = Vector2.ZERO
