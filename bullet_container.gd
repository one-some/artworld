class_name BulletManager extends Node2D

@onready var player = %PlayerCharacter
@onready var cam = %PlayerCam
var lines = []
var pp = PhysicsPointQueryParameters2D.new()
const GLOBAL_SPEED_MULTIPLIER = 60.0

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
		collisions = collisions.filter(
			func(x):
				if "state" not in x["collider"]: return true
				return x["collider"].state == Data.CharState.ACTIVE
		)
		
		if line.origin == BulletOrigin.PLAYER:
			collisions = collisions.filter(func(x):
				return not x["collider"].is_in_group("Player")
			)
		elif line.origin == BulletOrigin.ENEMY:
			collisions = collisions.filter(func(x):
				return not x["collider"].is_in_group("Enemy")
			)
		
		if collisions:
			for collision in collisions:
				if "_recieve_bullet" not in collision["collider"]: continue
				var collider = collision["collider"]
				
				var damage = clamp(
					200 * (max(0, (line.origin_loc - collider.global_position).length() - 100) ** -0.4),
					0,
					collider.max_health
				)

				collider._recieve_bullet(bvec, damage)
			
			lines.erase(line)
			# TODO: Preserve trail somehow...
			line.line.queue_free()
			bullet_report(line, BulletOutcome.HIT)
			continue
		
		# Lots of ugliness and unoptimized nonsense to fix later..
		# ..sry i needed to account for delta and timescale
		var real_line: Line2D = line.line
		var vec_delta = line.direction * delta * GLOBAL_SPEED_MULTIPLIER
		bvec += vec_delta
		real_line.clear_points()
		for i in range(10):
			real_line.add_point(bvec - (vec_delta / Engine.time_scale * i))
