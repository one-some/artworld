extends Node2D

func shoot_fx():
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shoot")
