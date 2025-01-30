extends Control

func tween_scale(new_scale: float, time: float) -> Tween:
	var tween = Utils.notime_tween().set_parallel(true)
	tween.tween_property($Top, "scale:y", new_scale, time)
	tween.tween_property($Bottom, "scale:y", new_scale, time)
	tween.play()
	return tween
