extends CharacterBody2D
class_name EnemyNPC

# --- SHARED VARIABLES ---
var speed = 80
var health = 100
var player = null 
var max_health = 100

# --- KNOCKBACK VARIABLES --- 
var knockback = Vector2.ZERO      
var knockback_strength = 400        
var knockback_friction = 1000      
var hit_count = 0
var hits_to_knockback = 5

var hurt_prev_super: String = "Passive"
var hurt_prev_sub: String = "Idle"
var facing_left: bool = false
@export var face_deadzone := 12.0 

# --- REFERENCES TO MACHINES ---
@onready var hfsm: FiniteStateMachine = $HFSM
@onready var anim = $AnimatedSprite2D

@onready var hitbox = $enemy_hitbox
@onready var hitbox_initial_x = 0.0

func _ready():
	if has_node("enemy_hitbox"):
		hitbox_initial_x = $enemy_hitbox.position.x
	
	var regen_timer = get_node_or_null("regen_cooldown") 
	
	if regen_timer:
		regen_timer.wait_time = 1.0 
		regen_timer.one_shot = false 
		regen_timer.start()         
		print(">> Regen System: ACTIVE")
	else:
		print(">> ERROR: Could not find 'regen_cooldown' Timer node!")

func update_facing_to_player():
	if player == null: 
		return
		
	var dx = player.global_position.x - global_position.x

	if dx > face_deadzone:
		facing_left = false
	elif dx < -face_deadzone:
		facing_left = true

	anim.flip_h = facing_left
	
	if hitbox:
		if facing_left:
			hitbox.position.x = -abs(hitbox_initial_x)
		else:
			hitbox.position.x = abs(hitbox_initial_x)

func go_hurt():
	hfsm.transition_to("Hurt")

@export var low_health_threshold := 40
@export var recovered_health_threshold := 60

func _process(_delta):
	update_behavior_state()

func update_behavior_state():
	if hfsm.current_state == null:
		return

	# 1. DEAD CHECK
	if hfsm.current_state.name == "Death":
		return

	# 2. HURT CHECK
	if hfsm.current_state.name == "Hurt":
		return

	var player_detected := (player != null)

	# Priority 1: Scared if low health
	if health <= low_health_threshold:
		if hfsm.current_state.name != "Scared":
			hfsm.transition_to("Scared", "LowHealth")
		return

	# Priority 2: Recovered Health Logic
	if health >= recovered_health_threshold:
		if player_detected:
			if hfsm.current_state.name != "Aggressive":
				hfsm.transition_to("Aggressive", "Health Above Threshold and Player within detection area")
		else:
			if hfsm.current_state.name != "Passive":
				hfsm.transition_to("Passive", "Health Above Threshold and Player is not within detection area")
		return

	# Priority 3: Normal Logic
	if player_detected:
		if hfsm.current_state.name != "Aggressive":
			hfsm.transition_to("Aggressive", "PlayerSeen")
	else:
		if hfsm.current_state.name != "Passive":
			hfsm.transition_to("Passive", "PlayerLost")

func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
		
	velocity += knockback 
	
	move_and_slide() 
	deal_with_damage() 
	update_health()

var can_take_damage = true
var player_in_attack_range = false

func deal_with_damage():
	if not (player_in_attack_range and global.player_current_attack):
		return

	if not can_take_damage:
		return

	health -= 10
	hit_count += 1
	$take_damage_cooldown.start()
	can_take_damage = false
	print("Enemy Health: ", health, " | Hit Count: ", hit_count)

	if hit_count >= hits_to_knockback:
		print("COMBO FINISHER! Knockback applied.")
		if player != null:
			var direction = (global_position - player.global_position).normalized()
			knockback = direction * knockback_strength
		hit_count = 0

	# Death check
	if health <= 0:
		hfsm.transition_to("Death", "Health=0") 
		return 

	# Scared check (Don't stop to play hurt anim if running away)
	if hfsm.current_state and hfsm.current_state.name == "Scared":
		return 

	go_hurt()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true

func _on_detection_body_entered(body):
	player = body
	print("Player Detected!") 

func _on_detection_body_exited(body):
	if body == player:
		player = null
		player_in_attack_range = false 
		print("Player Lost!")

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_range = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_range = false
		
func _on_regen_cooldown_timeout() -> void:
	if health < max_health:
		health += 5 
		
		if health > max_health:
			health = max_health
			
		update_health()
		print("Regen Tick: ", health) 
		
func update_health():
	var healthbar = $enemy_healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
