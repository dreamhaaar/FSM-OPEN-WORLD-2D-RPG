# Extends the base 'State' class. It is a Leaf Node in the DFA.
extends State

# PATIENCE OF THE NPC
@export var min_idle_time := 3.0
@export var max_idle_time := 6.0

# INTERNAL VARIABLES:
var _t := 0.0
var _target := 1.5

# run once when entering this state.
func enter():

	enemy.velocity = Vector2.ZERO
	if enemy.anim:
		enemy.anim.play("side_idle")
	
	_t = 0.0
	
	# random duration between 3s and 6s.
	_target = randf_range(min_idle_time, max_idle_time)

# MAIN LOOP: Runs 60 times/sec (Physics Tick)
func physics_update(delta: float):
	enemy.velocity = Vector2.ZERO

	_t += delta
	
	# TIMER DONE TIME TO WANDER NOW
	if _t >= _target:
		state_machine.transition_to("Wander")
