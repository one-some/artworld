extends Node2D

@onready var player = Utils.from_group("Player")
@onready var player_cam = Utils.from_group("PlayerCam")
@onready var enemy_manager = Utils.from_group("EnemyManager")

var flung = false

func fling() -> void:
	flung = true
	$TutorialLabel.hide_now()
	print("CHAAAA!")
	$Door.freeze = false
	$Door2.freeze = false
	$Door.linear_velocity = Vector2(1500, 600)
	$Door.angular_velocity = 5
	$Door2.linear_velocity = Vector2(1500, -600)
	$Door2.angular_velocity = -5
	
	await get_tree().create_timer(0.1).timeout
	$Door/CollisionPolygon2D.disabled = true
	$Door2/CollisionPolygon2D.disabled = true
	
	await player_cam.gawk_at(player.closest_enemy().global_position, 1.0, 1.5)
	await get_tree().create_timer(1.0).timeout
	
	enemy_manager.do_spawning = true
	for baddie in get_tree().get_nodes_in_group("Enemy"):
		baddie.state = Data.CharState.ACTIVE
	

func _process(delta: float) -> void:
	var dashing = player.movement_state == player.MovementState.DASHING
	
	#if not g:
		#$Door.set_collision_layer_value(2, not dashing)
		#$Door2.set_collision_layer_value(2, not dashing)
	
	if not dashing: return
	if flung: return
	var dist = self.global_position.distance_to(player.global_position)
	if dist > 100: return
	fling()
