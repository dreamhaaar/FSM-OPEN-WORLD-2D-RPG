extends CharacterBody2D

var enemy_in_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

# --- KNOCKBACK VARIABLES ---
var knockback_velocity = Vector2.ZERO
var knockback_friction = 800.0  # How quickly knockback slows down
var is_knocked_back = false
var last_attacking_enemy = null

const SPEED = 200.0
var current_direction = "none"
var attack_ip = false

func _ready():
	$AnimatedSprite2D.play("side_idle")

func _physics_process(delta: float) -> void:
	# Apply knockback if active
	if is_knocked_back:
		apply_knockback(delta)
	else:
		player_movement(delta)
	
	attack()
	update_health()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("ure dead")
		self.queue_free()

func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_direction = "right"
		play_animation(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_direction = "left"
		play_animation(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_direction = "down"
		play_animation(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_direction = "up"
		play_animation(1)
		velocity.y = -SPEED
		velocity.x = 0
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func play_animation(movement):
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
		last_attacking_enemy = body

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = false

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
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

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false

# --- KNOCKBACK FUNCTIONS ---
func take_damage(amount, attacker_position = null):
	health -= amount
	print("Player took damage! Health: ", health)
	
	# Apply knockback if attacker position is provided
	if attacker_position != null:
		apply_knockback_from_position(attacker_position)
	
	if health <= 0:
		player_alive = false
		health = 0
		print("You are dead")
		self.queue_free()

func apply_knockback_from_position(attacker_position):
	# Calculate direction from attacker to player (push player away from attacker)
	var direction = (global_position - attacker_position).normalized()
	# Apply knockback
	knockback_velocity = direction * 400.0  # Adjust 400.0 for stronger/weaker knockback
	is_knocked_back = true
	# Start knockback timer
	$knockback_timer.start()

func apply_knockback(delta):
	# Apply knockback velocity
	velocity = knockback_velocity
	# Gradually reduce knockback
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	
	# If knockback is very small, stop it
	if knockback_velocity.length() < 10.0:
		is_knocked_back = false
		knockback_velocity = Vector2.ZERO

func _on_knockback_timer_timeout():
	is_knocked_back = false
	knockback_velocity = Vector2.ZERO

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
