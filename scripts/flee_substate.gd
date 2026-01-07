# inherit and implement the state 
extends State

# THIS MAKES THE NPC RUN FAST
@export var flee_speed: float = 100.0
@export var anim_name: String = "side_walk"

# Track moving state for smoother transitions
var is_moving = false


# PLAY ANIMATOION
func enter():
	if enemy.anim:
		enemy.anim.play(anim_name)

func physics_update(_delta: float):

	if enemy.player == null:
		enemy.velocity = Vector2.ZERO
		if enemy.anim: enemy.anim.play("side_idle")
		return 

	var distance = enemy.global_position.distance_to(enemy.player.global_position)

	# TO STOP THE SPRITE FROM JITTERING
	var stop_threshold = 350.0 
	var start_threshold = 300.0
	
	if is_moving:
		if distance > stop_threshold:
			is_moving = false 
	else:
		if distance < start_threshold:
			is_moving = true 
			
# ANIMATION
	if not is_moving:
		enemy.velocity = Vector2.ZERO
		if enemy.anim: enemy.anim.play("side_idle")
	else:
		var direction = (enemy.global_position - enemy.player.global_position).normalized()
		enemy.velocity = direction * flee_speed
		enemy.move_and_slide()
		
		# Force Walk Animation
		if enemy.anim:
			if enemy.anim.animation != anim_name:
				enemy.anim.play(anim_name)
			
			# Face away from running direction
			if direction.x < -0.1:
				enemy.anim.flip_h = true
			elif direction.x > 0.1:
				enemy.anim.flip_h = false
