# NPC AUTOMATON IMPLEMENTED IN DETERMINISTIC
class_name FiniteStateMachine
extends Node

# Signal to notify UI or other systems when state changes (used for debugging)
signal state_changed(machine_name: String, from_state: String, to_state: String)

# Assigned in Inspector: The starting nodei is PASSIVE
@export var initial_state: State

# Assigned in Inspector: Name in the scene tree (PassiveSM, AggressiveSM, ScaredSM)
# Used for logging the current SM npc is in
@export var machine_name: String = ""

# Flag
@export var auto_run: bool = true 

# THE ACTIVE STATE
var current_state: State

# Lookup Table storing all possible states this machine owns
var states: Dictionary = {}

# Flag
var _start_attempted := false

func _ready():
	
	# Use node name in the inspector
	if machine_name == "":
		machine_name = name

	# BUILD THE LOOKUP TABLE FOR ITS STATES
	states.clear()
	for child in get_children():
		# Only look at children that are technically "States"
		if child is State:
			# Store them with lowercase keys so "Idle" and "idle" both work
			states[child.name.to_lower()] = child
			
			# STATE MACHINE CONTROLS THE STATES (CHILD)
			child.state_machine = self
			# THE NPC CONTROLLED
			child.enemy = _find_enemy_owner()


	# IF PARENT IS A STATE THEN MUST NOT RUN AUTOMATICALLY SINCE IT IS A SUB MACHINE
	var parent_node := get_parent()
	if parent_node is State:
		auto_run = false

	# Enable/Disable built-in Godot ticks based on auto_run
	set_process(auto_run)
	set_physics_process(auto_run)

	# 4. START THE MACHINE
	# call_deferred ensures the whole scene tree is ready before we enter the first state
	if auto_run:
		call_deferred("start")

# "INIT"
func _pick_default_initial_state() -> State:
	if states.has("idle"): return states["idle"]
	if states.has("chase"): return states["chase"]
	if states.has("flee"): return states["flee"]

	for child in get_children():
		if child is State:
			return child
	return null

func start():
	
	# To not start again if machine is already running
	if current_state != null:
		return

	# Handle missing initial_state assignment
	if initial_state == null:
		initial_state = _pick_default_initial_state()

	if initial_state == null:
		if not _start_attempted:
			_start_attempted = true
			push_error("FSM '%s': No initial_state set." % machine_name)
		return

	# INITIALIZE THE STATS FOR THE SUPERSTATES MACHINES
	current_state = initial_state
	_log_formal_transition("start", "init", current_state.name)
	current_state.enter()
	
# STOP MACNINE ON ABSORBING STATE (DEATH)
func stop():
	if current_state:
		current_state.exit()
	current_state = null
	_start_attempted = false


# GAME CONFIG TO UPDATE THE GAME WHAT STATE
func manual_update(delta: float):
	if current_state:
		current_state.update(delta)

# Called manually by a SuperState
func manual_physics_update(delta: float):
	if current_state:
		current_state.physics_update(delta)

# STANDARD GODOT PROCESS GAME CONFIG
func _process(_delta):
	pass

func _physics_process(delta):
	if auto_run:
		manual_physics_update(delta)

# TRANSITION LOGIC
func transition_to(key: String, trigger: String = ""):
	var target_key := key.to_lower()

	#  Does this specific machine have the requested state?
	if states.has(target_key):
		var target_state: State = states[target_key]

		# If asking to switch to self return.
		if current_state == target_state:
			return

		# Log data
		# FROM EMPTY TO THE CURRENT STATE, THE TRANSITION THAT WAS TRIGGERED
		# init
		var from_name := "∅"
		if current_state:
			from_name = current_state.name
			current_state.exit()

		# Update the pointer to the new state
		current_state = target_state
		
		# ENTER THE LOGIC OF THE NEW STATE (CURRENT STATE)
		current_state.enter()

		# Notify listeners and print the formal log
		state_changed.emit(machine_name, from_name, current_state.name)
		_log_formal_transition(from_name, trigger, current_state.name)
		return

	#  HIERARCHICAL 
	# IF THE LOCAL STATE  MACHINE DOESNT HAVE THE SUBSTATES THEN LOOK IN THE ROOT (HFSM)
	var parent := get_parent()
	# If my parent is a State (Aggressive) and has a Machine (FSM)
	if parent is State and parent.state_machine:
		# ...pass the request up the chain!
		parent.state_machine.transition_to(key, trigger)

# formatting the console output to look like Automata Theory math
func _log_formal_transition(prev: String, input_trigger: String, next: String):
	var color := "white"
	var mn := machine_name.to_lower()

	# Assign colors based on machine type for readability
	if "behavior" in mn or "hfsm" in mn or "sm" in mn:
		color = "yellow" # Structure changes (Passive -> Aggressive)

	#LOGBOOK
	if input_trigger != "":
		print_rich(" xxx [color=%s][%s] δ(%s, \"%s\") -> %s[/color]" % [color, machine_name, prev, input_trigger, next])
	else:
		print_rich(" xxx [color=%s][%s] δ(%s) -> %s[/color]" % [color, machine_name, prev, next])

# GAME CONFIG TO SEE WHICH SPRITE IS THE ENEMY
func _find_enemy_owner():
	var n: Node = self
	while n != null and not (n is EnemyNPC):
		n = n.get_parent()
	return n
