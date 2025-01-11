extends Node2D

var lines = []
var pp = PhysicsPointQueryParameters2D.new()

func _ready() -> void:
	pp.collide_with_areas = true 

func add_one(location: Vector2, direction: Vector2) -> void:
	var l2d = $StdLine.duplicate()
	l2d.add_point(location)
	self.add_child(l2d)
	lines.append({
		"direction": direction,
		"line": l2d
	})

func _process(delta: float) -> void:
	for line in lines:
		var bvec = line.line.get_point_position(0)
		
		pp.position = bvec
		var collisions = get_world_2d().direct_space_state.intersect_point(pp, 3)
		if collisions:
			lines.erase(line)
			
			# TODO: Preserve trail somehow...
			line.line.queue_free()
			
			for collision in collisions:
				if "_recieve_bullet" not in collision["collider"]: continue
				collision["collider"]._recieve_bullet()
			return
		
		bvec += line.direction
		line.line.add_point(bvec, 0)
		
		# Bad opt
		while line.line.get_point_count() > 7:
			line.line.remove_point(line.line.get_point_count() - 1)
