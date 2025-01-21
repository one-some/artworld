extends Control

func _process(delta: float) -> void:
	$Noise.texture.noise.offset += Vector3(0.4, 0.2, 0.0)
