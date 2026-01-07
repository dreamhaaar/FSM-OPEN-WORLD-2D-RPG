# inherit and implement the state 
extends State

var _locked_facing_left := false

func enter():
	enemy.velocity = Vector2.ZERO

	# player  is not attacking range, chase
	if enemy.player == null:
		state_machine.transition_to("Chase")
		return

	# sprite config
	enemy.update_facing_to_player()
	_locked_facing_left = enemy.facing_left
	enemy.anim.flip_h = _locked_facing_left
	enemy.anim.play("side_attack")
	perform_attack_sequence()

# SPRITES CONFIG
func perform_attack_sequence():
	await get_tree().create_timer(0.5).timeout
	
	# ENSURE THAT THE CONTROL IS ON HURT WHEN WE GOT ATTACKED
	if state_machine.current_state != self:
		return

	if not is_instance_valid(enemy) or enemy.player == null:
		state_machine.transition_to("Chase")
		return

	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	var hit_confirmed = enemy.player_in_attack_range or distance <= 40 # slightly forgiving

	if hit_confirmed and enemy.player.has_method("take_damage"):
		enemy.player.take_damage(10, enemy.global_position)

	# RECOVERY (1.0s)
	await get_tree().create_timer(1.0).timeout
	
	# ENSURE THAT THE CONTROL IS ON HURT WHEN WE GOT ATTACKED
	if state_machine.current_state != self:
		return

	if not is_instance_valid(enemy):
		return

	# PLAYER IS STILL CLOSE(DETECTION) THEN CHASE
	state_machine.transition_to("Chase")

# Keep npc frozen in place while attacking
func physics_update(_delta):
	enemy.velocity = Vector2.ZERO
	enemy.anim.flip_h = _locked_facing_left
