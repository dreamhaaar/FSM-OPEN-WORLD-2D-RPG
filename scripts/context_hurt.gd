# This script is shared by P_Hurt, A_Hurt, and S_Hurt nodes.
extends State

# --- DFA CONFIGURATION ---
# - P_Hurt node has this set to "Passive"
# - A_Hurt node has this set to "Aggressive"
# - S_Hurt node has this set to "Scared"
@export var return_to_state_name: String = "" 
@export var stun_duration: float = 0.5

func enter():
	# stop moving immediately upon taking damage.
	enemy.velocity = Vector2.ZERO
	
	# Note: Physics updates keep running in the background while this waits.
	await get_tree().create_timer(stun_duration).timeout
	
	# TRANSITION LOGIC
	# The stun is over. Now we must decide where to go next.
	_decide_exit()

func physics_update(_delta):
	#GAME CONFIG
	enemy.velocity = Vector2.ZERO

func _decide_exit():
	# IF DEATH IS BELOW 0 ENTER THE ABSORBING STATE
	if enemy.health <= 0:
		state_machine.transition_to("Death", "Health=0")
		return

	# IF NPC HEALTH IS BELOW THRESHOLD, GO TO SCARED 
	if enemy.get("low_health_threshold") and enemy.health <= enemy.low_health_threshold:
		state_machine.transition_to("Scared", "LowHealthCrit")
		return

	#BACK TO THE SUPERSTATE AFTER TAKING UP THE DAMAGE
	state_machine.transition_to(return_to_state_name, "HurtEnd")
