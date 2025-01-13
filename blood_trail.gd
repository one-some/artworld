extends Node

@onready var etc_container = get_tree().get_first_node_in_group("EtcContainer")
@onready var line = $Line2D
@onready var blood_boom = $"../BloodBlowUp"
var bleeding = false
var point_no = 0

func _ready() -> void:
	line.clear_points()
	line.reparent(etc_container, false)

var points = []

# ADS the god tamn point to the arraya.
func add_point(point: Vector2):
	# BAD
	for l in line.points:
		if point == l: return
	line.add_point(point)

func finish_up():
	await get_tree().create_timer(3).timeout
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0, 5)
	tween.tween_property(blood_boom, "modulate:a", 0, 5)
	tween.play()
	await tween.finished

func _process(delta: float) -> void:
	if not bleeding: return
	add_point($"..".global_position)
