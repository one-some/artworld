extends AudioStreamPlayer2D

func _ready() -> void:
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	self.play(randf() * self.stream.get_length())
	await get_tree().create_timer(randf_range(1.5, 4.0)).timeout
	self.stop()
	$Over.play()
	
	$Timer.wait_time = randf_range(5, 20)
	$Timer.start()
