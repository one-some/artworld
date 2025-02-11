extends RayCast2D

@onready var line: Line2D = $Line2D

func _process(delta: float) -> void:
	if not line:
		return
	
	var target_pos = self.target_position
	if self.is_colliding():
		target_pos = to_local(self.get_collision_point())

	line.set_point_position(1, target_pos)
	