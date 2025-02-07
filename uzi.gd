extends Node2D

@onready var bullet_container = Utils.from_group("BulletContainer")
@onready var player_cam = Utils.from_group("PlayerCam")
@export var shoot_time: float = 0.05

func shoot(rot: float):
	player_cam.shake(1)
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shoot")
	
	var offset = PI * randf_range(-0.005, 0.005)
	bullet_container.add_one(
		self.get_node("PointLight2D").global_position,
		Vector2.from_angle(rot + offset) * 30,
		BulletManager.BulletOrigin.PLAYER,
	)
