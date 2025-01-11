extends CharacterBody2D

@onready var player = %PlayerCharacter

func _recieve_bullet(where: Vector2):
	$AudioStreamPlayer2D.play()
	var blood = $Blood.duplicate()
	self.add_child(blood)
	
	var dir_vec = (self.global_position - player.global_position).normalized()
	
	blood.position += dir_vec * randf_range(-20, 20)
	
	blood.rotation = dir_vec.angle()
	blood.emitting = true
	blood.finished.connect(blood.queue_free)
