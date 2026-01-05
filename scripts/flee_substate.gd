extends State

@export var flee_speed: float = 100.0
@export var anim_name: String = "side_walk"

# Track moving state for smoother transitions
var is_moving = false

func enter():
	if enemy.anim:
		enemy.anim.play(anim_name)

func physics_update(_delta: float):
	# 1. PLAYER LOST LOGIC (THE FIX IS HERE)
	if enemy.player == null:
		# --- BUG WAS HERE ---
		# DO NOT call state_machine.transition_to("Passive") here.
		# If you do, enemy.gd will force it back to Scared instantly because HP is low.
		
		# CORRECT LOGIC: Just hide and wait for health regen.
		enemy.velocity = Vector2.ZERO
		if enemy.anim: enemy.anim.play("side_idle")
		return 

	var distance = enemy.global_position.distance_to(enemy.player.global_position)

	# 2. HYSTERESIS LOGIC (Prevents Jitter)
	var stop_threshold = 350.0 
	var start_threshold = 300.0
	
	if is_moving:
		if distance > stop_threshold:
			is_moving = false 
	else:
		if distance < start_threshold:
			is_moving = true 
			
	# 3. MOVEMENT APPLICATION
	if not is_moving:
		# SAFE DISTANCE: Stop and Catch Breath
		enemy.velocity = Vector2.ZERO
		if enemy.anim: enemy.anim.play("side_idle")
	else:
		# DANGER: Run Away!
		var direction = (enemy.global_position - enemy.player.global_position).normalized()
		enemy.velocity = direction * flee_speed
		enemy.move_and_slide()
		
		# Force Walk Animation
		if enemy.anim:
			if enemy.anim.animation != anim_name:
				enemy.anim.play(anim_name)
			
			# Face away from running direction
			if direction.x < -0.1:
				enemy.anim.flip_h = true
			elif direction.x > 0.1:
				enemy.anim.flip_h = false
