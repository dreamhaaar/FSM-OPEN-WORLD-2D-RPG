class_name FiniteStateMachine
extends Node

signal state_changed(machine_name: String, from_state: String, to_state: String)

@export var initial_state: State
@export var machine_name: String = ""
@export var auto_run: bool = true  # Root HFSM can true; sub-FSMs forced false

var current_state: State
var states: Dictionary = {}
var previous_state_name: String = ""

# Prevent repeated "initial_state not set" spam
var _start_attempted := false

func _ready():
	if machine_name == "":
		machine_name = name

	# Build state table
	states.clear()
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.enemy = _find_enemy_owner()

	# If nested under a State (sub-FSM), force manual ticking only
	var parent_node := get_parent()
	if parent_node is State:
		auto_run = false

	# Deterministic processing
	set_process(auto_run)
	set_physics_process(auto_run)

	# Auto-start only for root FSMs
	if auto_run:
		call_deferred("start")

func _pick_default_initial_state() -> State:
	# Prefer common defaults if present
	if states.has("idle"):
		return states["idle"]
	if states.has("chase"):
		return states["chase"]
	if states.has("flee"):
		return states["flee"]

	# Otherwise pick the first State child in scene order
	for child in get_children():
		if child is State:
			return child

	return null

func start():
	if current_state != null:
		return

	# If initial_state not set in Inspector, auto-pick one
	if initial_state == null:
		initial_state = _pick_default_initial_state()

	if initial_state == null:
		# Only warn once to avoid console spam
		if not _start_attempted:
			_start_attempted = true
			push_error("FSM '%s': initial_state is not set and no State children found." % machine_name)
		return

	current_state = initial_state
	current_state.enter()
	_log_formal_transition("start", "init", current_state.name)

func stop():
	if current_state:
		current_state.exit()
	current_state = null
	_start_attempted = false

func manual_update(delta: float):
	if current_state:
		current_state.update(delta)

func manual_physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

func _process(_delta):
	# We’re using physics ticks for behavior
	pass

func _physics_process(delta):
	if auto_run:
		manual_physics_update(delta)

func transition_to(key: String, trigger: String = ""):
	var target_key := key.to_lower()

	if states.has(target_key):
		var target_state: State = states[target_key]

		if current_state == target_state:
			return

		var from_name := "∅"
		if current_state:
			from_name = current_state.name
			previous_state_name = from_name
			current_state.exit()

		current_state = target_state
		current_state.enter()

		state_changed.emit(machine_name, from_name, current_state.name)
		_log_formal_transition(from_name, trigger, current_state.name)
		return

	# Bubble-up to parent machine if key not found
	var parent := get_parent()
	if parent is State and parent.state_machine:
		parent.state_machine.transition_to(key, trigger)

func _log_formal_transition(prev: String, input_trigger: String, next: String):
	var color := "white"
	var mn := machine_name.to_lower()

	if "behavior" in mn or "hfsm" in mn:
		color = "yellow"
	elif "movement" in mn:
		color = "cyan"
	elif "game" in mn:
		color = "green"

	if input_trigger != "":
		print_rich(" xxx [color=%s][%s] δ(%s, \"%s\") -> %s[/color]" % [color, machine_name, prev, input_trigger, next])
	else:
		print_rich(" xxx [color=%s][%s] δ(%s) -> %s[/color]" % [color, machine_name, prev, next])

func _find_enemy_owner():
	var n: Node = self
	while n != null and not (n is EnemyNPC):
		n = n.get_parent()
	return n
