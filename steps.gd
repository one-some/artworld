extends AudioStreamPlayer2D

const THRESHY = 60.0

var last_pos = self.global_position

func _process(delta: float) -> void:
	if self.global_position.distance_to(last_pos) < THRESHY:
		return

	last_pos = self.global_position
	self.play()