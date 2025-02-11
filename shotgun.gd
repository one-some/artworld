extends Weapon

func _ready() -> void:
	self.shoot_time = 0.6
	self.shake_oomf = 7.0
	self.base_damage = 50.0

func shoot(rot: float):
	self.shoot_fx()
	
	var offset = PI * randf_range(-0.005, 0.005)
	for i in range(-1, 2):
		var angle = i * (PI / 16.0)
		bullet_container.add_one(
			self,
			self.tip.global_position,
			Vector2.from_angle(rot + offset + angle) * 30,
			BulletManager.BulletOrigin.PLAYER,
		)
