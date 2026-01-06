extends CharacterBody2D
class_name EnemyNPC

# --- SHARED VARIABLES ---
var speed := 80
var health := 100
var max_health := 100
var player: Node2D = null

# --- KNOCKBACK VARIABLES ---
var knockback := Vector2.ZERO
var knockback_strength := 400
var knockback_friction := 1000
var hit_count := 0
var hits_to_knockback := 5

# --- HURT MEMORY (optional use by Hurt) ---
var hurt_prev_super: String = "Passive"
var hurt_prev_sub: String = "Idle"

# --- FACING ---
var facing_left := false
@export var face_deadzone := 12.0

# --- REFERENCES TO MACHINES ---
@onready var hfsm: FiniteStateMachine = $HFSM
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var hitbox = $enemy_hitbox
@onready var hitbox_initial_x := 0.0

var can_take_damage := true
var player_in_attack_range := false

# --- DETECTION DEBOUNCE (fix Player Lost/Detected spam) ---
var _lost_timer: Timer
var _pending_lost := false
@export var detection_lost_grace := 0.2  # seconds

func _ready():
	# Cache hitbox offset
	if has_node("enemy_hitbox"):
		hitbox_initial_x = $enemy_hitbox.position.x

	# ✅ Start HFSM *after* the whole scene tree is ready
	call_deferred("_start_hfsm_safely")

	# ✅ Setup debounce timer for "Player Lost"
	_lost_timer = Timer.new()
	_lost_timer.one_shot = true
	_lost_timer.wait_time = detection_lost_grace
	add_child(_lost_timer)
	_lost_timer.timeout.connect(_confirm_player_lost)

	# Regen timer
	var regen_timer := get_node_or_null("regen_cooldown")
	if regen_timer:
		regen_timer.wait_time = 1.0
		regen_timer.one_shot = false
		regen_timer.start()
		print(">> Regen System: ACTIVE")
	else:
		print(">> ERROR: Could not find 'regen_cooldown' Timer node!")

func _start_hfsm_safely():
	# HFSM must have initial_state set in Inspector, otherwise start() won't do anything
	if hfsm and hfsm.current_state == null:
		hfsm.start()

func update_facing_to_player():
	if player == null:
		return

	var dx := player.global_position.x - global_position.x

	if dx > face_deadzone:
		facing_left = false
	elif dx < -face_deadzone:
		facing_left = true

	anim.flip_h = facing_left

	if hitbox:
		hitbox.position.x = ( -abs(hitbox_initial_x) if facing_left else abs(hitbox_initial_x) )

func go_hurt():
	# ✅ Safety guard
	if hfsm == null or hfsm.current_state == null:
		return

	# Store previous superstate + substate (optional, for Hurt returns)
	hurt_prev_super = hfsm.current_state.name
	hurt_prev_sub = "null"
	if hfsm.current_state is SuperState:
		hurt_prev_sub = (hfsm.current_state as SuperState).get_substate_name()

	hfsm.transition_to("Hurt", "DamageTaken")

func _physics_process(delta):
	if hfsm == null or hfsm.current_state == null:
		return

	# Knockback decay
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)

	velocity += knockback
	move_and_slide()

	deal_with_damage()
	update_health()

func deal_with_damage():
	if hfsm == null or hfsm.current_state == null:
		return

	if hfsm.current_state.name == "Death":
		return

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
			var direction := (global_position - player.global_position).normalized()
			knockback = direction * knockback_strength
		hit_count = 0

	if health <= 0:
		hfsm.transition_to("Death", "Health=0")
		return

	if hfsm.current_state.name == "Scared":
		return

	go_hurt()

func _on_take_damage_cooldown_timeout():
	can_take_damage = true

# --- Detection (debounced) ---
func _on_detection_body_entered(body):
	player = body
	_pending_lost = false
	if _lost_timer and _lost_timer.time_left > 0:
		_lost_timer.stop()
	print("Player Detected!")

func _on_detection_body_exited(body):
	if body == player:
		_pending_lost = true
		if _lost_timer:
			_lost_timer.start()

func _confirm_player_lost():
	if _pending_lost:
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
		health = min(max_health, health + 5)
		update_health()
		print("Regen Tick: ", health)

func update_health():
	var healthbar = $enemy_healthbar
	healthbar.value = health
	healthbar.visible = health < 100
