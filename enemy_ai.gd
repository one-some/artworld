extends Node

@onready var body = $".."
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var weapon_chassis = $"../Weapon"

func _process(delta: float) -> void:
	if body.dead: return
	
	weapon_chassis.rotation = (player.global_position - body.global_position).angle()
	
	var left = weapon_chassis.rotation > PI / 2 and weapon_chassis.rotation < (PI * 3 / 2)
	weapon_chassis.scale.y = -1 if left else 1
