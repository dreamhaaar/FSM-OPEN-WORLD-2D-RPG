extends State

@export var min_idle_time := 3.0
@export var max_idle_time := 6.0

var _t := 0.0
var _target := 1.5

func enter():
	enemy.velocity = Vector2.ZERO
	if enemy.anim:
		enemy.anim.play("side_idle")
	


	_t = 0.0
	_target = randf_range(min_idle_time, max_idle_time)

func update(delta: float):
	_t += delta
	if _t >= _target:
		state_machine.transition_to("Wander")

func physics_update(_delta: float):
	enemy.velocity = Vector2.ZERO
