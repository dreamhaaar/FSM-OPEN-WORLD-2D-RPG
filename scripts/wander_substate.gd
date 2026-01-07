# inherit and implement the state 
extends State

@export var wander_radius: float = 200.0
@export var wander_speed: float = 20.0
@export var wander_time: float = 2.0 

var start_position: Vector2
var target_position: Vector2
var wander_timer: float = 0.0

func enter():
	#  udate start_position to CURRENT location every time we start wandering
	start_position = enemy.global_position 
	
	# random point location here
	var random_x = randf_range(-wander_radius, wander_radius)
	var random_y = randf_range(-wander_radius, wander_radius)
	target_position = start_position + Vector2(random_x, random_y)
	
	# play Animation
	if enemy.anim:
		enemy.anim.play("side_walk")
	
	# in case npc got stuck on walls switch
	# fast-forward the timer to its maximum value
	wander_timer = wander_time

func physics_update(delta: float):
	var direction = (target_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(target_position)
	
	wander_timer -= delta
	if wander_timer <= 0:
		# TIMES UP GO IDLE
		state_machine.transition_to("Idle")
		return

	# IF NPC REACHED THE LOCATION ALREADY GO TO IDLE
	if distance < 10.0:
		state_machine.transition_to("Idle")
		return

	# MOVE
	enemy.velocity = direction * wander_speed
	enemy.move_and_slide()
	
	# FLIP SPRITE
	if enemy.anim:
		if direction.x < 0:
			enemy.anim.flip_h = true
		elif direction.x > 0:
			enemy.anim.flip_h = false
