extends Control

# MAYBE JUST MAYBE IT REALLY SUCKS TO BE WEIRD FOR HEAT LEVEL. I WANT NO FOLLOWER/CATCHUP

@export var bar_type = BarType.HEALTH
@onready var inner_bar = $Progress
@onready var catchup_bar = $Catchup
var target_width = self.size.x

enum BarType {
	HEALTH,
	HEAT
}

func _ready() -> void:
	catchup_bar.size.x = self.size.x

func set_value(value: int, max_value: int):
	target_width = float(value) / float(max_value) * self.size.x
	
	if bar_type == BarType.HEALTH:
		$NUM.text = "%s (QUANTITATIVE) PERCENT HEALTHY." % value
	
	# Old inner bar width
	inner_bar.size.x = target_width

func _process(delta: float) -> void:
	inner_bar.texture.noise.offset += Vector3(0.4, 0.2, 0.0)

	var norm = (abs(target_width - inner_bar.size.x) / float(self.size.x)) + 0.1
	catchup_bar.size.x = move_toward(catchup_bar.size.x, target_width, norm * 1528.0 * delta)
