extends State

@export var wander_radius: float = 200.0
@export var wander_speed: float = 20.0
@export var wander_time: float = 2.0 

var start_position: Vector2
var target_position: Vector2
var wander_timer: float = 0.0

func enter():
	# 1. Update start_position to CURRENT location every time we start wandering
	start_position = enemy.global_position 
	
	# 2. Pick a random point around HERE
	var random_x = randf_range(-wander_radius, wander_radius)
	var random_y = randf_range(-wander_radius, wander_radius)
	target_position = start_position + Vector2(random_x, random_y)
	
	# 3. Play Animation
	if enemy.anim:
		enemy.anim.play("side_walk") # Make sure this matches your animation name!
	
	# 4. Set a safety timer (give up if we get stuck)
	wander_timer = wander_time

func physics_update(delta: float):
	var direction = (target_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(target_position)
	
	# --- TIMER CHECK ---
	wander_timer -= delta
	if wander_timer <= 0:
		# Time is up! Go back to Idle.
		state_machine.transition_to("Idle")
		return

	# --- ARRIVAL CHECK ---
	if distance < 10.0:
		# We reached the spot! Go back to Idle.
		state_machine.transition_to("Idle")
		return

	# --- MOVE ---
	enemy.velocity = direction * wander_speed
	enemy.move_and_slide()
	
	# --- FLIP SPRITE ---
	if enemy.anim:
		if direction.x < 0:
			enemy.anim.flip_h = true
		elif direction.x > 0:
			enemy.anim.flip_h = false
