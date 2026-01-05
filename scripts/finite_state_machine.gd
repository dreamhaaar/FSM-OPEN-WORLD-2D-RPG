class_name FiniteStateMachine
extends Node

signal state_changed(machine_name: String, from_state: String, to_state: String)

@export var initial_state: State
@export var machine_name: String = ""
@export var auto_run: bool = true  

var current_state: State
var states: Dictionary = {}
var previous_state_name: String = ""

func _ready():
	# Wait for the parent (Enemy) to be ready first
	await get_parent().ready

	if machine_name == "":
		machine_name = name

	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.enemy = _find_enemy_owner()

	if auto_run:
		start()

func start():
	if initial_state:
		current_state = initial_state
		current_state.enter()
		_log_formal_transition("start", "init", current_state.name)


func stop():
	if current_state:
		current_state.exit()
	current_state = null

func manual_update(delta: float):
	if current_state:
		current_state.update(delta)

func manual_physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

func _process(delta):
	if auto_run:
		manual_update(delta)

func _physics_process(delta):
	if auto_run:
		manual_physics_update(delta)
func transition_to(key: String, trigger: String = ""):
	var target_key = key.to_lower()

	if states.has(target_key):
		var target_state = states[target_key]
		

		if current_state == target_state:
			return 

		
		if current_state:
			previous_state_name = current_state.name 
			current_state.exit()
		
		current_state = target_state
		current_state.enter()
		
		state_changed.emit(machine_name, previous_state_name, current_state.name)
		_log_formal_transition(previous_state_name, trigger, current_state.name)
		return


	var parent_node = get_parent()
	if parent_node is State and parent_node.state_machine:
		parent_node.state_machine.transition_to(key, trigger)

func _log_formal_transition(prev: String, input_trigger: String, next: String):
	var color = "white"
	if "behavior" in machine_name.to_lower() or "hfsm" in machine_name.to_lower():
		color = "yellow"
	elif "movement" in machine_name.to_lower():
		color = "cyan"
	elif "game" in machine_name.to_lower():
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
