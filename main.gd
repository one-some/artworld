extends Node2D

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	# $CanvasModulate.color = Color("0a0a0a")
	$CanvasModulate.color = Color.BLACK