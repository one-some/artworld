extends Node2D

const EnemyScene = preload("res://enemy.tscn")
@onready var door = $"../Doors"
@onready var player = $"../PlayerCharacter"
@onready var new_floor_visuals = Utils.from_group("NewFloorVisuals")

var do_spawning = false
var current_floor = {
	number = 1,
	spawns_left = 10,
	in_transition = false,
}

func _on_spawn_timeout() -> void:
	if not do_spawning: return
	if current_floor.spawns_left <= 0: return
	if current_floor.in_transition: return

	current_floor.spawns_left -= 1

	var point = NavigationServer2D.region_get_random_point(
		$"../NavigationRegion2D".get_rid(),
		1,
		true
	)

	var baddie = EnemyScene.instantiate()
	baddie.position = point#Vector2(randf() * 1000, randf() * 1000)
	baddie.state = Data.CharState.ACTIVE
	self.add_child(baddie)

func move_baddie(baddie: CharacterBody2D) -> void:
	if baddie.state != Data.CharState.ACTIVE: return
	
	var direction_to_plr = baddie.global_position.direction_to(player.global_position)
	var target_pos = player.global_position - (direction_to_plr * 200)

	if baddie.global_position.distance_to(target_pos) < 10:
		return
	
	baddie.nav_target = target_pos

func do_floor_transfer() -> void:
	current_floor.in_transition = true
	current_floor.number += 1

	current_floor.spawns_left = 10

	print("OK")
	await get_tree().create_timer(2.0).timeout
	await new_floor_visuals.show_floor_msg(current_floor.number)
	await get_tree().create_timer(5.0).timeout
	print("STOOOP")
	# UPDATE (By Jamie):
	# Poop hahha  poop poop Poop butt sex poop sex sex sex Boobs Vagina
	# Penis Asshole Boobs Virus Virus Virus in my computer BOOBS Weed
	# Drugs Cocaine
	current_floor.in_transition = false

func _process(delta: float) -> void:
	if current_floor.in_transition: return

	var alive = 0
	var baddies = get_tree().get_nodes_in_group("Enemy")

	for baddie in baddies:
		if baddie.state != Data.CharState.DEAD: alive += 1
		move_baddie(baddie)
	
	if not current_floor.spawns_left and not alive:
		do_floor_transfer()