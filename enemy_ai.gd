extends Node

@onready var body = $".."
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var weapon_chassis = $"../Weapon"
@onready var bullet_container = get_tree().get_first_node_in_group("BulletContainer")

func _ready() -> void:
	await get_tree().create_timer(randf()).timeout
	$Fire.start()

func _process(delta: float) -> void:
	if body.dead: return
	
	weapon_chassis.rotation = (player.global_position - body.global_position).angle()
	
	var left = weapon_chassis.rotation > PI / 2.0 or weapon_chassis.rotation < -PI / 2.0
	weapon_chassis.scale.y = -1 if left else 1

func shoot() -> void:
	if body.dead: return

	var offset = PI * randf_range(-0.005, 0.005)
	bullet_container.add_one(
		$"../Weapon/PointLight2D".global_position,
		Vector2.from_angle(weapon_chassis.rotation + offset) * 30,
		BulletManager.BulletOrigin.ENEMY,
	)
	

func _on_fire_timeout() -> void:
	shoot()
