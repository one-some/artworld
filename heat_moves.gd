extends Node

@onready var player = %PlayerCharacter
@onready var player_guy = player.get_node("Guy")
@onready var cam = %PlayerCam
@onready var cam_xform = $"../CamXFORM"
@onready var letterbox = get_tree().get_first_node_in_group("Letterbox")
var in_heat_move = false
var selected_enemies = []

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("heat"):
		do_heat_move()

func closest_enemy(max_dist: float):
	var enemies = get_tree().get_nodes_in_group("Enemy") \
		.map(func(x): return [x, player.global_position.distance_to(x.global_position)]) \
		.filter(func(x): return x[1] < max_dist)
	enemies.sort_custom(func(a, b): return [a[1] > b[1]])
	if not enemies: return null
	return enemies[-1][0]

func deselect_all() -> void:
	for enemy in selected_enemies:
		enemy.get_node("Guy").self_modulate = Color.WHITE
	selected_enemies = []

func select(enemy: CharacterBody2D) -> void:
	if not in_heat_move: return
	selected_enemies.append(enemy)
	enemy.get_node("Guy").self_modulate = Color("ff7a7a")
	player_guy.rotation = PI - player_guy.global_position.angle_to(enemy.global_position)
	
	enemy.die(
		player.global_position.direction_to(enemy.global_position),
		1000.0,
		enemy.global_position
	)
	

func do_heat_move() -> void:
	if in_heat_move: return
	in_heat_move = true
	player.scripted_rotation = true
	
	deselect_all()
	
	var target = closest_enemy(1500.0)
	if not target: return
	
	Utils.set_timescale(0.001)
	cam_xform.update_position = false
	cam.allow_rotation = true
	var rot = player.global_position.angle_to_point(target.global_position)
	if abs(rot) > PI:
		if rot > 0:
			rot -= PI * 2
		else:
			rot += PI * 2
	
	cam.position_smoothing_enabled = false
	
	var lb_tween = letterbox.tween_scale(1.0, 2.0)
	var tween = Utils.notime_tween().set_parallel(true)
	tween.tween_method(
		func(x): cam.alter_fov("heat", x),
		0.0,
		-0.3,
		4.0
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		cam,
		"global_position",
		(player.global_position + target.global_position) / 2.0,
		0.5
	).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "rotation", rot, 1.0).set_trans(Tween.TRANS_SINE)
	tween.play()
	
	await lb_tween.finished
	await get_tree().create_timer(Engine.time_scale / 1.0).timeout
	#await get_tree().create_timer(Engine.time_scale / 1.0).timeout
	
	#await get_tree().create_timer(1.0).timeout
	
	letterbox.tween_scale(0.0, 2.0)
	
	cam.alter_fov("heat", 0)
	tween = Utils.notime_tween().set_parallel(true)
	tween.tween_property(cam, "rotation", 0, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(cam, "position", player.global_position, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(x): cam.alter_fov("heat", x),
		-0.3,
		0.0,
		2.0
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.play()
	await tween.finished
	cam.allow_rotation = false
	cam.position_smoothing_enabled = true

	await letterbox.tween_scale(0.0, 1.0).finished
	
	Utils.set_timescale(1.0)
	in_heat_move = false
	deselect_all()
	player.scripted_rotation = false
	cam_xform.update_position = true
