# SuperState.gd
class_name SuperState
extends State

@export var sub_fsm_path: NodePath
@export var default_substate: StringName = &""

var sub_fsm: FiniteStateMachine

func enter():
	# Get the nested FSM
	sub_fsm = get_node_or_null(sub_fsm_path) as FiniteStateMachine
	if sub_fsm == null:
		push_error("SuperState '%s': sub_fsm_path is invalid (%s)" % [name, str(sub_fsm_path)])
		return

	# Start the sub-FSM if it isn't running yet
	if sub_fsm.current_state == null:
		sub_fsm.start()

	# Force the default child state on entry (HFSM rule)
	if default_substate != &"":
		sub_fsm.transition_to(String(default_substate))

func update(delta: float):
	if sub_fsm:
		sub_fsm.manual_update(delta)

func physics_update(delta: float):
	if sub_fsm:
		sub_fsm.manual_physics_update(delta)

func exit():
	if sub_fsm:
		# Use the FSM's dedicated stop function
		sub_fsm.stop()

func get_substate_name() -> String:
	if sub_fsm and sub_fsm.current_state:
		return sub_fsm.current_state.name
	return "null"

func set_substate(key: String) -> void:
	if sub_fsm:
		sub_fsm.transition_to(key)
