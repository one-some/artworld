extends Control

@onready var combo_label = $ComboLabel
@onready var low_pass = AudioServer.get_bus_effect(1, 0)
@onready var cam = get_tree().get_first_node_in_group("PlayerCam")
@export var gradient: Gradient
var combo = 0
var actual_score = 0
var visual_score = 0

var target_combo_fov = 0
var combo_fov = 0
var can_lower = true

func do_combo_fx(increasing):
	if increasing:
		add_points(1000)
		combo += 1
		
		can_lower = false
		$ComboLabel/Timer.start()
		target_combo_fov += 0.01
	else:
		combo = 0
	combo_label.text = "x%s" % combo

func _bullet_report(status: BulletManager.BulletOutcome):
	do_combo_fx(status == BulletManager.BulletOutcome.HIT)

func add_points(points: int) -> void:
	self.actual_score += points

func _process(delta: float) -> void:
	# SCORE
	var points_scale = (abs(actual_score - visual_score) / 1000.0) + 3.0
	points_scale = clamp(points_scale, 1.0, 8.0)
	
	var norm_scale = (points_scale - 3.0) / 5.0
	
	$Score.set("theme_override_colors/font_color", gradient.sample(norm_scale)) 
	$Score.scale = Vector2(points_scale, points_scale)
	
	visual_score = move_toward(
		visual_score,
		actual_score,
		ceil(abs(actual_score -  visual_score) / 15.0)
		#33
	)
	#e$Score.text = Utils.commatize(visual_score)
	$Score.text = str(visual_score)
	
	# COMBO
	if can_lower:
		target_combo_fov -= 0.005

	target_combo_fov = clamp(target_combo_fov, 0, 0.2)
	
	combo_fov = move_toward(
		combo_fov,
		target_combo_fov,
		0.001 if target_combo_fov > combo_fov else 0.01
	)
	
	cam.alter_fov("combo", combo_fov)
	
	# IS IT LAGGY?
	AudioServer.set_bus_effect_enabled(1, 0, combo_fov > 0)
	low_pass.cutoff_hz = max(100, 12000 - (combo_fov * (12000 / 0.2)))

func _on_timer_timeout() -> void:
	can_lower = true
	
