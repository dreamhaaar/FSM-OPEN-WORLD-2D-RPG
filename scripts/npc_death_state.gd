extends State

func enter():
	# 1. Stop all movement immediately
	enemy.velocity = Vector2.ZERO
	
	# 2. Disable collisions so the player can't hit the dead body
	enemy.find_child("CollisionShape2D").set_deferred("disabled", true)
	
	# 3. Play the Death Animation
	enemy.anim.play("die") 
	
	# 4. Wait for the animation to finish
	await get_tree().create_timer(1).timeout
	
	# 5. NOW we delete the enemy
	enemy.queue_free()

func physics_update(delta):
	# Ensure they don't slide while dying
	enemy.velocity = Vector2.ZERO
