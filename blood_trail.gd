extends Node

@onready var line = $Line2D
var bleeding = false
var point_no = 0

func _ready() -> void:
	$Line2D.clear_points()

var points = []

# ADS the god tamn point to the arraya.
func add_point(point: Vector2):
	point_no = (point_no + 1) % 6
	if point_no != 0: return
	print(point)
	line.add_point(point)

func _process(delta: float) -> void:
	if not bleeding: return
	add_point($"..".global_position)
