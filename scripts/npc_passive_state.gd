extends State

var regen_rate = 10.0 # How much health to gain per second

func update(delta):

	# Only heal if we are hurt
	if enemy.health < enemy.max_health:
		# Add health over time (multiplied by delta for smoothness)
		enemy.health += regen_rate * delta
		
		# Prevent health from going over the maximum
		if enemy.health > enemy.max_health:
			enemy.health = enemy.max_health
			
	# If player is detected, stop healing and switch to Aggressive
	if enemy.player != null:
		state_machine.transition_to("Aggressive")
		enemy.movement_sm.transition_to("Chase")
