class_name SuperState
extends State

# The internal FSM for the 3 superstates (P, A, S)
@export var sub_fsm: FiniteStateMachine

func enter() -> void:
	if sub_fsm == null:
		return

	# GAME CONFIG
	# Ensure the substates does NOT auto-run on its own 
	sub_fsm.auto_run = false
	sub_fsm.set_process(false)
	sub_fsm.set_physics_process(false)

	# START THE MACHINE ONCE IF NO CURRENT STATE
	if sub_fsm.current_state == null:
		sub_fsm.start()

func exit() -> void:
	if sub_fsm == null:
		return
	pass
	
# GAME CONFIG
func physics_update(delta: float) -> void:
	# Run the nested FSM only while this superstate is active
	if sub_fsm:
		sub_fsm.manual_physics_update(delta)

# GET THE CURRENT SUBSTATE EG IN THE AGGGRESIVE -> CHASE
func get_substate_name() -> String:
	if sub_fsm and sub_fsm.current_state:
		return sub_fsm.current_state.name
	return "None"
