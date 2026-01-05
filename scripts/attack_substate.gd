extends State

var _locked_facing_left := false

func enter():
	enemy.velocity = Vector2.ZERO

	if enemy.player == null:
		state_machine.transition_to("Chase")
		return


	enemy.update_facing_to_player()
	_locked_facing_left = enemy.facing_left
	enemy.anim.flip_h = _locked_facing_left

	enemy.anim.play("side_attack")
	perform_attack_sequence()

func perform_attack_sequence():
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(enemy) or enemy.player == null:
		state_machine.transition_to("Chase")
		return

	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	var hit_confirmed = enemy.player_in_attack_range or distance <= 35

	if hit_confirmed and enemy.player.has_method("take_damage"):
		enemy.player.take_damage(10, enemy.global_position)

	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(enemy):
		return

	state_machine.transition_to("Chase")

func physics_update(_delta):
	enemy.velocity = Vector2.ZERO
	enemy.anim.flip_h = _locked_facing_left
