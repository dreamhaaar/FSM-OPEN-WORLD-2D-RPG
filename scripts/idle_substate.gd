extends State

@export var min_idle_time := 3.0
@export var max_idle_time := 6.0

var _t := 0.0
var _target := 1.5

func enter():
	# 1. Stop moving
	enemy.velocity = Vector2.ZERO
	
	if enemy.anim:
		enemy.anim.play("side_idle")
	
	# 2. Reset timer
	_t = 0.0
	_target = randf_range(min_idle_time, max_idle_time)

# --- DELETE func update(delta) --- 

# --- USE THIS INSTEAD ---
func physics_update(delta: float):
	# 1. Ensure velocity stays zero (physics engines can be slippery)
	enemy.velocity = Vector2.ZERO
	
	# 2. Count time here
	_t += delta
	
	# 3. Time's up -> Transition
	if _t >= _target:
		state_machine.transition_to("Wander")
