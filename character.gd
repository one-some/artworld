extends CharacterBody2D

@onready var anim_player = $Guy/Weapon/AnimationPlayer
var timer = Timer.new()
var last_direction = Vector2(0, 0)
@onready var dash_particles = $GPUParticles2D
@onready var dash_particles_mat = dash_particles.process_material
@onready var visual_body = $Guy

enum MovementState {
	STANDARD,
	DASHING
}

const DASH_TIME_SEC = 0.1
var dash_start = 0
var movement_state = MovementState.STANDARD

func _ready() -> void:
	timer.wait_time = 0.15
	
	self.add_child(timer)
	timer.timeout.connect(shoot)
	
	anim_player.speed_scale = anim_player.get_animation("shoot").length / timer.wait_time

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()
		timer.start()
	elif Input.is_action_just_released("shoot"):
		timer.stop()
		
	if Input.is_action_just_pressed("dash"):
		dash()

func dash():
	if movement_state != MovementState.STANDARD:
		return
	dash_start = Time.get_ticks_msec()
	movement_state = MovementState.DASHING
	
	dash_particles.emitting = true
	dash_particles.amount = 12
	await get_tree().create_timer(DASH_TIME_SEC).timeout
	dash_particles.emitting = false
	
	movement_state = MovementState.STANDARD

func shoot() -> void:
	$Guy/Weapon.shoot_fx()
	$PlayerCam.shake(1)
	var offset = PI * randf_range(-0.005, 0.005)
	$"../BulletContainer".add_one(
		$Guy/Weapon/PointLight2D.global_position,
		Vector2.from_angle(visual_body.rotation + offset) * 30
	)

func dash_ease(x: float) -> float:
	return 1 - (1 - x) * (1 - x)

func _physics_process(delta: float) -> void:
	if movement_state == MovementState.DASHING:
		dash_particles_mat.angle_max = 180 - visual_body.global_rotation_degrees
		dash_particles_mat.angle_min = dash_particles_mat.angle_max
	
		var progress = (Time.get_ticks_msec() - dash_start) / 1000.0 / DASH_TIME_SEC
		self.velocity = (last_direction * 650) + last_direction * 8900 * progress
		var fov_mult = (sin(progress * PI) / 20)
		$PlayerCam.alter_fov("dash", fov_mult)
		self.move_and_slide()
		return
	
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
