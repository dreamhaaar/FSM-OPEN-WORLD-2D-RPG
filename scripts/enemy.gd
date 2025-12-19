extends CharacterBody2D
class_name EnemyNPC

# --- SHARED VARIABLES ---
var speed = 80
var health = 100
var player = null # Reference to player
var max_health = 100

# --- REFERENCES TO MACHINES ---
@onready var behavior_sm = $BehaviorSM
@onready var movement_sm = $MovementSM
@onready var anim = $AnimatedSprite2D

func _ready():
	# Ensure the machines are running
	pass

func _physics_process(delta):
	move_and_slide() # Global physics movement
	deal_with_damage() # Keep damage logic global, or move to a StatusSM
	update_health()

# --- DAMAGE LOGIC (Kept from your original file) ---
var can_take_damage = true
var player_in_attack_range = false

func deal_with_damage():
	if player_in_attack_range and global.player_current_attack == true:
		if can_take_damage:
			health -= 10
			$take_damage_cooldown.start()
			can_take_damage = false
			print("Enemy Health: ", health)
			
			if health <= 0:
				movement_sm.transition_to("Death")
				behavior_sm.process_mode = Node.PROCESS_MODE_DISABLED
				

func _on_take_damage_cooldown_timeout():
	can_take_damage = true

# --- SENSORS (Signals) ---
# Link these in the Inspector to the Area2D signals



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
