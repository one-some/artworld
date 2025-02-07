extends Node2D

enum Weapon {
	PISTOL,
	SHOTGUN,
	UZI,
	SNIPER
}

var hotkeys = [
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9
]

@onready var player = Utils.from_group("Player")
@onready var hotbar = Utils.from_group("Hotbar")
var active_weapon = Weapon.PISTOL
var weapon_node = null
var timing = {
	fire_duration_sec = 1.0,
	start = 0.0,
	autofire = false
}

func stop_shooting() -> void:
	timing.autofire = false

func try_shoot() -> void:
	if player.movement_state not in [player.MovementState.STANDARD, player.MovementState.DASHING]:
		return

	if Time.get_ticks_msec() - timing.start < timing.fire_duration_sec * 1000.0:
		return
	
	timing.start = Time.get_ticks_msec()

	weapon_node.shoot($"..".global_rotation)

func switch_weapon(weapon: Weapon) -> void:
	active_weapon = weapon
	for c in self.get_children():
		if not c.is_in_group("Weapon"): continue
		c.visible = false
	weapon_node = self.get_node(Weapon.find_key(active_weapon))
	weapon_node.visible = true
	
	timing.fire_duration_sec = float(weapon_node.shoot_time)
	
	var anim_player = weapon_node.get_node("AnimationPlayer")
	anim_player.speed_scale = anim_player.get_animation("shoot").length / timing.fire_duration_sec

func _input(event: InputEvent) -> void:
	if player.movement_state == player.MovementState.FROZEN: return

	if event.is_action_pressed("shoot"):
		try_shoot()
		# We start holding down action here
		timing.autofire = true
	elif event.is_action_released("shoot"):
		stop_shooting()

	# HOTBAR switch
	if event is InputEventKey:
		if not event.is_pressed(): return
		
		var idx = hotkeys.find(event.keycode)
		if idx == -1: return
		if idx >= len(Weapon): return
		hotbar.switch_slot(idx)
		
		switch_weapon(Weapon.values()[idx])

func _process(delta: float) -> void:
	if timing.autofire:
		try_shoot()

func _ready() -> void:
	self.call_deferred("switch_weapon", active_weapon)
