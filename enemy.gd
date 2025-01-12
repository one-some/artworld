extends CharacterBody2D

@onready var player = %PlayerCharacter
@export var max_health = 100
@export var health = max_health
var dead = false
var dead_pos

func _recieve_bullet(where: Vector2):
	if dead:
		return

	$AudioStreamPlayer2D.play()
	var blood = $Blood.duplicate()
	self.add_child(blood)
	
	var player_diff = self.global_position - player.global_position
	var dir_vec = player_diff.normalized()
	var damage = clamp(200 * (max(0, player_diff.length() - 100) ** -0.4), 0, max_health)
	
	blood.position += dir_vec * randf_range(-20, 20)
	blood.amount = ceil(damage * 0.75) ** 1.2
	blood.rotation = dir_vec.angle()
	
	blood.emitting = true
	blood.finished.connect(blood.queue_free)
	
	health = clamp(health - damage, 0, max_health)
	
	if not health:
		die(dir_vec, damage, where)

func die(dir_vec: Vector2, last_damage: float, hit_pos: Vector2) -> void:
	if dead:
		return
	dead = true
	print("AIIEEEE")
	$BloodBlowUp.emitting = true
	
	var rot = angle_difference(dir_vec.angle(), (self.global_position - hit_pos).angle()) / PI
	var pos_trans_time = clamp(last_damage, 30, 80) / 80.0
	rot += sign(rot) * clamp(last_damage, 30, 80) / 120
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0,pos_trans_time)
	print(rot)
	tween.tween_property(
		self,
		"rotation",
		self.rotation + rot,
		pos_trans_time / 2
	)
	tween.tween_property(
		self,
		"position",
		self.position + dir_vec * last_damage * 3,
		pos_trans_time
		
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
	await get_tree().create_timer(pos_trans_time / 2)
	$BloodTrail.bleeding = true
	await tween.finished
	self.queue_free()

func _process(delta: float) -> void:
	$ProgressBar.value = move_toward($ProgressBar.value, health, 2)
