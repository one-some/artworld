extends Weapon

func _ready() -> void:
	self.shoot_time = 0.05
	self.base_damage = 2.0

func shoot(rot: float):
	self.shoot_fx()
	
	var offset = PI * randf_range(-0.05, 0.05)
	bullet_container.add_one(
		self,
		self.get_node("PointLight2D").global_position,
		Vector2.from_angle(rot + offset) * 30,
		BulletManager.BulletOrigin.PLAYER,
	)
