class_name SuperState
extends State

# The internal FSM for this superstate (e.g., AggressiveSM with Chase/Attack)
@export var sub_fsm: FiniteStateMachine

func enter() -> void:
	if sub_fsm == null:
		return

	# Ensure the sub-FSM does NOT auto-run on its own (SuperState ticks it manually)
	sub_fsm.auto_run = false
	sub_fsm.set_process(false)
	sub_fsm.set_physics_process(false)

	# ✅ Start only the first time ever
	if sub_fsm.current_state == null:
		sub_fsm.start()
	# else: resume previous substate as-is (no reset)

func exit() -> void:
	if sub_fsm == null:
		return

	# ✅ DO NOT stop() here, because stop() clears current_state and causes re-init spam.
	# We just "pause" it by not ticking it anymore.
	# (Since this SuperState won't call manual_physics_update when inactive,
	# the sub-FSM is effectively paused.)

	pass

func physics_update(delta: float) -> void:
	# Run the nested FSM only while this superstate is active
	if sub_fsm:
		sub_fsm.manual_physics_update(delta)

func get_substate_name() -> String:
	if sub_fsm and sub_fsm.current_state:
		return sub_fsm.current_state.name
	return "None"
