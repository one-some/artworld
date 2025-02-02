extends Node2D

enum Weapon {
	PISTOL,
	SHOTGUN
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


@onready var hotbar = Utils.from_group("Hotbar")
var active_weapon = Weapon.PISTOL
var weapon_node = null
var weapon_timer = Timer.new()

func switch_weapon(weapon: Weapon) -> void:
	active_weapon = weapon
	for c in self.get_children():
		c.visible = false
	weapon_node = self.get_node(Weapon.find_key(active_weapon))
	weapon_node.visible = true
	
	weapon_timer.wait_time = weapon_node.shoot_time
	
	var anim_player = weapon_node.get_node("AnimationPlayer")
	anim_player.speed_scale = anim_player.get_animation("shoot").length / weapon_timer.wait_time

func _input(event: InputEvent) -> void:
	if event is not InputEventKey: return
	if not event.is_pressed(): return
	
	var idx = hotkeys.find(event.keycode)
	if idx == -1: return
	if idx >= len(Weapon): return
	hotbar.switch_slot(idx + 1)
	
	switch_weapon(Weapon.values()[idx])

func _ready() -> void:
	self.call_deferred("switch_weapon", active_weapon)
