class_name BulletManager extends Node2D

@onready var player = %PlayerCharacter
@onready var cam = %PlayerCam

var lines: Array[Bullet] = []
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

class Bullet:
	var position: Vector2
	var base_velocity: Vector2
	var origin_type: BulletOrigin
	var origin_position: Vector2
	var line_node: Line2D
	var origin_weapon: Node

	func _init(
		position: Vector2,
		base_velocity: Vector2,
		origin_type: BulletOrigin,
		line_node: Line2D,
		origin_weapon: Node,
	) -> void:
		self.position = position
		self.base_velocity = base_velocity
		self.origin_type = origin_type
		self.origin_position = position
		self.line_node = line_node
		self.origin_weapon = origin_weapon

func add_one(
	weapon: Node, # HACK: Not `Weapon` because of hack with enemy_ai
	location: Vector2,
	base_velocity: Vector2,
	origin_type: BulletOrigin,
) -> void:
	var l2d = $StdLine.duplicate()
	l2d.add_point(location)
	self.add_child(l2d)

	lines.append(Bullet.new(
		location,
		base_velocity,
		origin_type,
		l2d,
		weapon
	))

func bullet_report(line, outcome: BulletOutcome):
	if line.origin_type != BulletOrigin.PLAYER: return
	for wanter in get_tree().get_nodes_in_group("WantsBulletReport"):
		wanter._bullet_report(outcome)

func _process(delta: float) -> void:
	# /u/Juulpower
	var camera_size = get_viewport_rect().size * cam.zoom
	var dist_threshold = camera_size.length() * 0.75
	
	for bullet in lines:
		if bullet.position.distance_to(player.position) > dist_threshold:
			lines.erase(bullet)
			bullet.line_node.queue_free()
			bullet_report(bullet, BulletOutcome.MISS)
			return
		
		# Lots of ugliness and unoptimized nonsense to fix later..
		# ..sry i needed to account for delta and timescale
		var vec_delta = bullet.base_velocity * delta * GLOBAL_SPEED_MULTIPLIER
		var old_bullet_pos = bullet.position
		bullet.position += vec_delta

		var collision_interpolation_steps = max(1, floor(vec_delta.length() / 20))
		# print("interpolating with ", collision_interpolation_steps)

		var colliders = []
		for i in range(collision_interpolation_steps):
			var sample_pos = old_bullet_pos + (vec_delta / collision_interpolation_steps) * i
			pp.position = sample_pos

			var these_collisions = get_world_2d().direct_space_state.intersect_point(pp, 3)

			for collider in these_collisions.map(func(x): return x["collider"]):
				if collider in colliders: continue
				if "state" in collider and collider.state != Data.CharState.ACTIVE: continue

				if bullet.origin_type == BulletOrigin.PLAYER and collider.is_in_group("Player"):
					continue
				if bullet.origin_type == BulletOrigin.ENEMY and collider.is_in_group("Enemy"):
					continue
				colliders.append(collider)
		
		var hit = false
		for collider in colliders:
			if "_recieve_bullet" not in collider: continue

			hit = true

			var distance_traveled = bullet.origin_position.distance_to(collider.global_position)
			var damage = bullet.origin_weapon.damage_for(distance_traveled)
			collider._recieve_bullet(bullet.position, damage)
			break
		
		if colliders:
			lines.erase(bullet)
			# TODO: Preserve trail somehow...
			bullet.line_node.queue_free()
			bullet_report(bullet, BulletOutcome.HIT if hit else BulletOutcome.MISS)
			continue

		# Make trail
		bullet.line_node.clear_points()
		for i in range(10):
			bullet.line_node.add_point(bullet.position - (vec_delta / Engine.time_scale * i))
