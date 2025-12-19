class_name FiniteStateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	await get_parent().ready
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.enemy = get_parent()
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	else:
		# Warn you if you forgot to set it in the Inspector
		push_warning("FiniteStateMachine: Initial State not set for " + name)

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func transition_to(key: String):
	if not states.has(key.to_lower()):
		print("State Machine Error: State not found -> " + key)
		return
	
	# FIX: Only call exit() if we actually HAVE a current state
	if current_state:
		current_state.exit()
	
	current_state = states[key.to_lower()]
	current_state.enter()
