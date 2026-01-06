extends State

@export var anim_name: String = "death"
@export var despawn_time: float = 1.0 # How long body stays before disappearing

func enter():

	enemy.velocity = Vector2.ZERO
	

	if enemy.anim:
		enemy.anim.play(anim_name)
	

	var collider = enemy.get_node_or_null("CollisionShape2D")
	if collider:
		collider.set_deferred("disabled", true)
	

	enemy.set_physics_process(false) 
	

	await get_tree().create_timer(despawn_time).timeout
	enemy.queue_free()

func physics_update(_delta):
	
	enemy.velocity = Vector2.ZERO
