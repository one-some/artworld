extends Node2D

const EnemyScene = preload("res://enemy.tscn")
@onready var player = $"../PlayerCharacter"

func _on_spawn_timeout() -> void:
	var baddie = EnemyScene.instantiate()
	baddie.position = Vector2(randf() * 1000, randf() * 1000)
	self.add_child(baddie)

func move_baddie(baddie: CharacterBody2D) -> void:
	if baddie.dead: return
	
	var direction_to_plr = baddie.global_position.direction_to(player.global_position)
	var target_pos = player.global_position - (direction_to_plr * 300)

	if baddie.global_position.distance_to(target_pos) < 10:
		return
	
	baddie.nav_target = target_pos

func _process(delta: float) -> void:
	for baddie in get_tree().get_nodes_in_group("Enemy"):
		move_baddie(baddie)
