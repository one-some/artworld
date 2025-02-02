extends CharacterBody2D

@onready var player = Utils.from_group("Player")
@export var max_health = 100
@export var health = max_health
@onready var etc_container = Utils.from_group("EtcContainer")
@onready var blood_boom = $BloodBlowUp
@onready var sprite = $Guy
@onready var heat_move_manager = Utils.from_group("HeatMoveManager")
@onready var score_ui = Utils.from_group("ScoreUI")

var state = Data.CharState.INACTIVE
var nav_target = Vector2(0, 0)

func _recieve_bullet(where: Vector2, damage: float) -> bool:
	if state != Data.CharState.ACTIVE:
		return false

	$AudioStreamPlayer2D.play()
	var blood = $Blood.duplicate()
	self.add_child(blood)
	
	var player_diff = self.global_position - player.global_position
	var dir_vec = player_diff.normalized()
	
	blood.position += dir_vec * randf_range(-20, 20)
	blood.amount = ceil(damage * 0.75) ** 1.2
	blood.rotation = dir_vec.angle()
	
	blood.emitting = true
	blood.finished.connect(blood.queue_free)
	
	score_ui.add_points(damage)
	health = clamp(health - damage, 0, max_health)
	
	if not health:
		die(dir_vec, damage, where)
	return true

func blood_blow_up() -> void:
	blood_boom.reparent(etc_container, false)
	blood_boom.global_position = self.global_position
	blood_boom.global_rotation = self.global_rotation
	blood_boom.emitting = true
	await get_tree().create_timer(blood_boom.lifetime / 2.0).timeout
	
	# https://github.com/godotengine/godot/issues/50824
	blood_boom.interpolate = false
	#blood_boom.fixed_fps = 0
	blood_boom.speed_scale = 0

func die(dir_vec: Vector2, last_damage: float, hit_pos: Vector2) -> void:
	last_damage = clamp(last_damage, 0, 200.0)

	$Crunch.play()

	if state == Data.CharState.DEAD:
		return
	state = Data.CharState.DEAD

	$CollisionPolygon2D.disabled = true
	$Walkie.die()

	blood_blow_up()
	player.alter_heat(10)
	
	var rot = angle_difference(dir_vec.angle(), (self.global_position - hit_pos).angle()) / PI
	var pos_trans_time = clamp(last_damage, 30, 80) / 80.0
	rot += sign(rot) * clamp(last_damage, 30, 80) / 120
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0,pos_trans_time)
	tween.tween_property(
		self,
		"rotation",
		self.rotation + rot,
		pos_trans_time / 2
	)
	tween.tween_property(
		self,
		"position",
		self.position + dir_vec * max(last_damage, 50) * 3,
		pos_trans_time
		
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	$BloodTrail.bleeding = true
	tween.play()
	await tween.finished
	$Guy.visible = false
	$BloodTrail.finish_up()
	
	self.queue_free()

func _process(delta: float) -> void:
	$ProgressBar.value = move_toward($ProgressBar.value, health, 2)
	
	if state != Data.CharState.ACTIVE: return
	self.velocity = self.global_position.direction_to(nav_target) * delta * 23000.0
	self.move_and_slide()
	#self.global_position = self.global_position.move_toward(nav_target, 10.0)

func _input(event):
	if event is not InputEventMouseButton: return
	if not event.is_pressed(): return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if not sprite.is_pixel_opaque(sprite.get_local_mouse_position()): return
	heat_move_manager.select(self)
	# FALLOUT STYLE SHOOT THING
	#if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == BUTTON_LEFT:
		#var pos = position + offset - ( (texture.get_size() / 2.0) if centered else Vector2() ) # added this 2
		#if Rect2(pos, texture.get_size()).has_point(event.position): # added this
			#get_tree().set_input_as_handled() # if you don't want subsequent input callbacks to respond to this input
