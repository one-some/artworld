extends Node2D

const EnemyScene = preload("res://enemy.tscn")
@onready var door = $"../Doors"
@onready var player = $"../PlayerCharacter"
var enemies_left = 10
var floor_done = false
var do_spawning = false

func _ready() -> void:
	enemies_left = 100

func _on_spawn_timeout() -> void:
	if not do_spawning: return
	if enemies_left <= 0: return
	enemies_left -= 1
	if not enemies_left: floor_done = true

	var baddie = EnemyScene.instantiate()
	baddie.position = Vector2(randf() * 1000, randf() * 1000)
	baddie.state = Data.CharState.ACTIVE
	self.add_child(baddie)

func move_baddie(baddie: CharacterBody2D) -> void:
	if baddie.state != Data.CharState.ACTIVE: return
	
	var direction_to_plr = baddie.global_position.direction_to(player.global_position)
	var target_pos = player.global_position - (direction_to_plr * 200)

	if baddie.global_position.distance_to(target_pos) < 10:
		return
	
	baddie.nav_target = target_pos

func _process(delta: float) -> void:
	for baddie in get_tree().get_nodes_in_group("Enemy"):
		move_baddie(baddie)
