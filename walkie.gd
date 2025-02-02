extends AudioStreamPlayer2D

@onready var guy = $".."

func _ready() -> void:
	$Timer.wait_time = randf_range(5, 20)
	$Timer.start()

func die() -> void:
	self.stop()
	$Over.stop()

func _on_timer_timeout() -> void:
	if guy.state == Data.CharState.ACTIVE:
		self.play(randf() * self.stream.get_length())
		await get_tree().create_timer(randf_range(1.5, 4.0)).timeout

		if guy.state != Data.CharState.ACTIVE:
			return

		self.stop()
		$Over.play()
	
	$Timer.wait_time = randf_range(5, 20)
	$Timer.start()
