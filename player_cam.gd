extends Camera2D

# Assume they are equal lol
@onready var std_zoom = self.zoom.x

var fov_additions = {}

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
	
	self.rotation = rotate_toward(self.rotation, 0, 0.001)
