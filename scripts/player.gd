extends CharacterBody2D

var enemy_in_range = false
var enemy_attack_cooldown = true
@onready var sfx_slash: AudioStreamPlayer = $"../sfx_slash"
@onready var sfx_footstep: AudioStreamPlayer = $"../sfx_footstep"
@onready var sfx_jump: AudioStreamPlayer = $"../sfx_jump"
@onready var sfx_damagegrunt: AudioStreamPlayer = $"../sfx_damagegrunt"

# --- SHARED VARIABLES ---
var health = 100
var player_alive = true
const SPEED = 200.0
var current_direction = "none"
var attack_ip = false

# --- JUMP VARIABLES (New) ---
var z_height = 0.0      # How high off the ground we are
var z_velocity = 0.0    # Speed of ascent/descent
var gravity = 800.0     # How fast we fall back down
var jump_force = 250.0  # Initial push upwards

# --- KNOCKBACK VARIABLES --- 
var knockback = Vector2.ZERO        
var knockback_strength = 400           
var knockback_friction = 1000        
var hit_count = 0         
var hits_to_knockback = 3

func _ready():
	$AnimatedSprite2D.play("side_idle")

func _physics_process(delta: float) -> void:
	# 1. Handle Movement (X/Y Axis)
	player_movement(delta)
	
	# 2. Handle Jumping (Z Axis - Visual Only)
	handle_jump(delta)
	
	# 3. Handle Knockback
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
		velocity += knockback
	
	move_and_slide() 
	
	attack()
	update_health()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("Player dead")
		self.queue_free()

func handle_jump(delta):
	# If we are on the ground, allow jumping
	if z_height == 0:
		if Input.is_action_just_pressed("jump"):
			sfx_jump.play()
			z_velocity = jump_force
	
	# Apply "Fake" Gravity
	if z_height > 0 or z_velocity != 0:
		z_velocity -= gravity * delta
		z_height += z_velocity * delta
		
		# Prevent falling below ground
		if z_height <= 0:
			z_height = 0
			z_velocity = 0
	
	# Update the Visual Sprite Position
	# We move the sprite UP (negative Y) based on Z-Height
	$AnimatedSprite2D.offset.y = -z_height

func player_movement(delta):
	# Standard movement logic
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("right"):
		current_direction = "right"
		play_animation(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("left"):
		current_direction = "left"
		play_animation(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down") or Input.is_action_pressed("down"):
		current_direction = "down"
		play_animation(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_up") or Input.is_action_pressed("up"):
		current_direction = "up"
		play_animation(1)
		velocity.y = -SPEED
		velocity.x = 0
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
	
func take_damage(amount, attacker_pos):
	health -= amount
	hit_count += 1  
	
	sfx_damagegrunt.play()
	print("Player took damage! Health: ", health, " | Hit Count: ", hit_count)
	
	# --- CHECK FOR COMBO KNOCKBACK ---
	if hit_count >= hits_to_knockback:
		print("PLAYER STAGGERED! Knockback applied.")
		
		var direction = (global_position - attacker_pos).normalized()

		# Apply the push
		knockback = direction * knockback_strength
		
		# Reset the counter
		hit_count = 0
	else:
		pass

func play_animation(movement):
	# Don't change walk animations if we are mid-air (optional, remove check if preferred)
	# if z_height > 0: return 

	var direction = current_direction
	var animated = $AnimatedSprite2D
	
	if direction == "right":
		animated.flip_h = false
		if movement == 1:
			animated.play("right_walk")
		elif movement == 0:
			if attack_ip == false:
				animated.play("side_idle")
			
	elif direction == "left":
		animated.flip_h = true
		if movement == 1:
			animated.play("right_walk")
		elif movement == 0:
				if attack_ip == false:
					animated.play("side_idle")
			
	elif direction == "down":
		animated.flip_h = true
		if movement == 1:
			animated.play("front_walk")
		elif movement == 0:
				if attack_ip == false:
					animated.play("front_idle")
			
	elif direction == "up":
		animated.flip_h = true
		if movement == 1:
			animated.play("back_walk")
		elif movement == 0:
				if attack_ip == false:
					animated.play("back_idle")
	
func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = false

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	
func attack():
	# Prevent attacking while jumping? Uncomment next line if desired
	# if z_height > 0: return

	var direction = current_direction
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		if direction == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		elif direction == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()	
		elif direction == "up":
			$AnimatedSprite2D.play("back_attack")
			$deal_attack_timer.start()
		elif direction == "down":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		sfx_slash.play()

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false

func update_health():
	var health_bar = $health_bar
	health_bar.value = health
	if health >= 100:
		health_bar.visible = false
	else:
		health_bar.visible = true

func _on_region_timer_timeout():
	if health < 100:
		health += 5
		if health > 100:
			health = 100
	if health <= 0:
		health = 0
