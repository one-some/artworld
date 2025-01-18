extends Node

var notime_tweens = []

func sum(iter):
	var out = 0
	for v in iter:
		out += v
	return out

func from_group(group: String):
	return get_tree().get_first_node_in_group(group)

func notime_tween() -> Tween:
	# Timescale independant
	var tween = create_tween()
	tween.set_speed_scale(1.0 / Engine.time_scale)
	notime_tweens.append(tween)
	return tween

func set_timescale(scale: float):
	Engine.time_scale = scale
	for tween in notime_tweens:
		print(tween)
		tween.set_speed_scale(1.0 / Engine.time_scale)
