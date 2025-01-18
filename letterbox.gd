extends Control

func tween_scale(scale: float, time: float) -> Tween:
	var tween = Utils.notime_tween().set_parallel(true)
	tween.tween_property($Top, "scale:y", scale, time)
	tween.tween_property($Bottom, "scale:y", scale, time)
	tween.play()
	return tween
