extends CharacterBody2D

var last_direction = Vector2(0, 0)
@onready var dash_particles = $GPUParticles2D
@onready var dash_particles_mat = dash_particles.process_material
@onready var visual_body = $Guy
@onready var timer = $Guy/Weapon.weapon_timer

var scripted_rotation = false
var max_health = 200
var health = max_health

var heat = 100
var max_heat = heat

enum MovementState {
	STANDARD,
	DASHING,
	FROZEN
}

const DASH_TIME_SEC = 0.1
var dash_start = 0
var movement_state = MovementState.STANDARD

func _ready() -> void:
	self.add_child(timer)
	timer.timeout.connect(shoot)
	
	self.call_deferred("alter_health", 0)
	self.call_deferred("alter_heat", 0)

func set_state(new_state) -> void:
	movement_state = new_state
	if new_state == MovementState.FROZEN:
		timer.stop()

func _input(event: InputEvent) -> void:
	if movement_state == MovementState.FROZEN: return
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
		timer.start()
	elif Input.is_action_just_released("shoot"):
		timer.stop()
		
	if Input.is_action_just_pressed("dash"):
		dash()

func closest_enemy(max_dist: float = 6000.0):
	var enemies = get_tree().get_nodes_in_group("Enemy") \
		.map(func(x): return [x, self.global_position.distance_to(x.global_position)]) \
		.filter(func(x): return x[1] < max_dist)
	enemies.sort_custom(func(a, b): return a[1] > b[1])
	if not enemies: return null
	return enemies[-1][0]

func alter_health(delta: float) -> void:
	self.health = clamp(self.health + round(delta), 0, self.max_health)
	Utils.from_group("HealthBar").set_value(self.health, self.max_health)
	if not self.health:
		self.health = self.max_health

func alter_heat(delta: float) -> void:
	self.heat = clamp(self.heat + round(delta), 0, self.max_heat)
	Utils.from_group("HeatBar").set_value(self.heat, self.max_heat)

func _recieve_bullet(where: Vector2, damage: float) -> bool:
	self.alter_health(-damage)
	return true

func dash():
	if movement_state != MovementState.STANDARD:
		return
	
	if heat < 7: return
	alter_heat(-7)
	
	dash_start = Time.get_ticks_msec()
	movement_state = MovementState.DASHING
	
	dash_particles.emitting = true
	dash_particles.amount = 12
	await get_tree().create_timer(DASH_TIME_SEC).timeout
	dash_particles.emitting = false
	
	movement_state = MovementState.STANDARD

func shoot() -> void:
	if $HeatMoves.in_heat_move: return
	$Guy/Weapon.weapon_node.shoot(visual_body.rotation)

func dash_ease(x: float) -> float:
	return 1 - (1 - x) * (1 - x)

func _physics_process(sdelta: float) -> void:
	if movement_state == MovementState.DASHING:
		dash_particles_mat.angle_max = 180 - visual_body.global_rotation_degrees
		dash_particles_mat.angle_min = dash_particles_mat.angle_max
	
		var progress = (Time.get_ticks_msec() - dash_start) / 1000.0 / DASH_TIME_SEC
		self.velocity = (last_direction * 650) + last_direction * 8900 * progress
		var fov_mult = (sin(progress * PI) / 20)
		$PlayerCam.alter_fov("dash", fov_mult)
		self.move_and_slide()
		return
	
	if movement_state != MovementState.STANDARD:
		return
	
	if not scripted_rotation:
		var rel_cart = get_global_mouse_position() - self.global_position
		visual_body.rotation = -atan2(rel_cart.x, rel_cart.y) + (PI / 2)
		
		var left = visual_body.rotation > PI / 2 and visual_body.rotation < (PI * 3 / 2)
		$Guy/Weapon.scale.y = -1 if left else 1
	
	var direction = Vector2(0, 0)
	if Input.is_action_pressed("left"): direction.x -= 1
	if Input.is_action_pressed("right"): direction.x += 1
	if Input.is_action_pressed("up"): direction.y -= 1
	if Input.is_action_pressed("down"): direction.y += 1
	direction = direction.normalized()
	
	if direction.length():
		last_direction = direction
	
	self.velocity = direction.normalized() * 650
	self.move_and_slide()
