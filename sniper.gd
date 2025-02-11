extends Weapon

func _ready() -> void:
	self.shoot_time = 1.05
	self.base_damage = 1000.0

func shoot(rot: float):
	self.shoot_fx()
	
	bullet_container.add_one(
		self,
		self.get_node("PointLight2D").global_position,
		Vector2.from_angle(rot) * 100.0,
		BulletManager.BulletOrigin.PLAYER,
	)
