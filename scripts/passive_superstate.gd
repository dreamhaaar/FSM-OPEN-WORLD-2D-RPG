extends State

var regen_rate = 10.0 

func update(delta):

	if enemy.health < enemy.max_health:
		enemy.health += regen_rate * delta
		

		if enemy.health > enemy.max_health:
			enemy.health = enemy.max_health
			

	if enemy.player != null:
		state_machine.transition_to("Aggressive")
		enemy.movement_sm.transition_to("Chase")
