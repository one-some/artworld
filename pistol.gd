extends Weapon

func _ready() -> void:
	self.shoot_time = 0.15
	self.base_damage = 10.0

func shoot(rot: float):
	self.shoot_fx()
	
	var offset = PI * randf_range(-0.005, 0.005)
	bullet_container.add_one(
		self,
		self.tip.global_position,
		Vector2.from_angle(rot + offset) * 30,
		BulletManager.BulletOrigin.PLAYER,
	)
