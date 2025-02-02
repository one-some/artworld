extends Camera2D

# Assume they are equal lol
@onready var player = Utils.from_group("Player")
@onready var std_zoom = self.zoom.x

var fov_additions = {}
var allow_rotation = false

func gawk_at(new_pos: Vector2, speed: float, duration: float):
	player.movement_state = player.MovementState.FROZEN
	$"../CamXFORM".update_position = false
	self.global_position = $"..".global_position
	
	var tween = Utils.notime_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", new_pos, speed)
	tween.play()
	
	await tween.finished
	await get_tree().create_timer(duration).timeout
	
	tween = Utils.notime_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", $"..".global_position, speed)
	tween.play()
	await tween.finished
	$"../CamXFORM".update_position = true
	player.movement_state = player.MovementState.STANDARD

func alter_fov(key: String, add: float):
	fov_additions[key] = add
	
	if not fov_additions[key]:
		fov_additions.erase(key)

func shake(severity: float):
	self.rotation += severity / 100 / PI * (-1 if randf() < 0.5 else 1)

func _process(delta: float) -> void:
	# Hello godot no sum function okie dokie whatevr...
	var sum = std_zoom - Utils.sum(fov_additions.values())
	self.zoom = Vector2(sum, sum)
	
	if not allow_rotation:
		self.rotation = rotate_toward(self.rotation, 0, 0.001)