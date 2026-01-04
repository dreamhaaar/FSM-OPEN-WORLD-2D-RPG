extends CharacterBody2D
class_name EnemyNPC

# --- SHARED VARIABLES ---
var speed = 80
var health = 100
var player = null # Reference to player
var max_health = 100

# --- KNOCKBACK VARIABLES ---
var knockback_velocity = Vector2.ZERO
var knockback_friction = 600.0  # How quickly knockback slows down
var is_knocked_back = false

# --- REFERENCES TO MACHINES ---
@onready var behavior_sm = $BehaviorSM
@onready var movement_sm = $MovementSM
@onready var anim = $AnimatedSprite2D

func _ready():
	# Ensure the machines are running
	pass

func _physics_process(delta):
	# Apply knockback if active
	if is_knocked_back:
		apply_knockback(delta)
	
	move_and_slide() # Global physics movement
	deal_with_damage() # Keep damage logic global, or move to a StatusSM
	update_health()

# --- DAMAGE LOGIC 
var can_take_damage = true
var player_in_attack_range = false

func deal_with_damage():
	if player_in_attack_range and global.player_current_attack == true:
		if can_take_damage:
			health -= 10
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Enemy Health: ", health)
			
			# Apply knockback
			if player != null:
				apply_player_knockback()
			
			if health <= 0:
				movement_sm.transition_to("Death")
				behavior_sm.process_mode = Node.PROCESS_MODE_DISABLED

# --- KNOCKBACK FUNCTIONS ---
func apply_player_knockback():
	if player != null:
		# Calculate direction from player to enemy (push enemy away from player)
		var direction = (global_position - player.global_position).normalized()
		# Apply knockback
		knockback_velocity = direction * 300.0  # Adjust 300.0 for stronger/weaker knockback
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

func _on_take_damage_cooldown_timeout():
	can_take_damage = true

func _on_knockback_timer_timeout():
	is_knocked_back = false
	knockback_velocity = Vector2.ZERO

func _on_detection_body_entered(body):
		player = body
		print("Player Detected!") # DEBUG PRINT

func _on_detection_body_exited(body):
		player = null
		print("Player Lost!") # DEBUG PRINT

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_range = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_range = false

func _on_regen_cooldown_timeout() -> void:
	pass # Replace with function body.

func update_health():
	var healthbar = $enemy_healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
