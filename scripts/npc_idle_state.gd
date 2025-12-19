extends State

func enter():
	# When we enter Idle, stop moving and play the idle animation
	enemy.velocity = Vector2.ZERO
	enemy.anim.play("front_idle") # Check if your animation is named "front_idle" or "side_idle"

func physics_update(delta):
	# Force velocity to zero every frame so the NPC doesn't slide
	enemy.velocity = Vector2.ZERO
