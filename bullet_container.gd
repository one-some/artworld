class_name BulletManager extends Node2D

@onready var player = %PlayerCharacter
@onready var cam = %PlayerCam
var lines = []
var pp = PhysicsPointQueryParameters2D.new()

enum BulletOutcome {
	HIT,
	MISS,
}

enum BulletOrigin {
	PLAYER,
	ENEMY
}

func _ready() -> void:
	pp.collide_with_areas = true 

func add_one(location: Vector2, direction: Vector2, origin: BulletOrigin) -> void:
	var l2d = $StdLine.duplicate()
	l2d.add_point(location)
	self.add_child(l2d)
	lines.append({
		"direction": direction,
		"line": l2d,
		"origin": origin,
		"origin_loc": location
	})

func bullet_report(line, outcome: BulletOutcome):
	if line.origin != BulletOrigin.PLAYER: return
	for wanter in get_tree().get_nodes_in_group("WantsBulletReport"):
		wanter._bullet_report(outcome)

func _process(delta: float) -> void:
	# /u/Juulpower
	var camera_size = get_viewport_rect().size * cam.zoom
	var dist_threshold = camera_size.length() * 0.75
	
	for line in lines:
		var bvec = line.line.get_point_position(0)
		
		if bvec.distance_to(player.position) > dist_threshold:
			lines.erase(line)
			line.line.queue_free()
			bullet_report(line, BulletOutcome.MISS)
			return
		
		pp.position = bvec
		var collisions = get_world_2d().direct_space_state.intersect_point(pp, 3)
		if collisions:
			lines.erase(line)
			
			# TODO: Preserve trail somehow...
			line.line.queue_free()
			bullet_report(line, BulletOutcome.HIT)
			
			for collision in collisions:
				if "_recieve_bullet" not in collision["collider"]: continue
				var collider = collision["collider"]
				
				var damage = clamp(
					200 * (max(0, (line.origin_loc - collider.global_position).length() - 100) ** -0.4),
					0,
					collider.max_health
				)
				
				if collider.is_in_group("Player") and line.origin == BulletOrigin.PLAYER:
					continue
					
				if collider.is_in_group("Enemy") and line.origin == BulletOrigin.ENEMY:
					continue

				collider._recieve_bullet(bvec, damage)
			return
		
		bvec += line.direction
		line.line.add_point(bvec, 0)
		
		# Bad opt
		while line.line.get_point_count() > 7:
			line.line.remove_point(line.line.get_point_count() - 1)
