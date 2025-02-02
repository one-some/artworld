extends Node

const DISTANCE_THRESHOLD = 150
@onready var player = $".."
var valid_pool = []

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"): return

	var sorted = valid_pool.map(func(x): return [x, x.global_position.distance_to(player.global_position)])
	sorted.sort_custom(func(a, b): return a[1] > b[1])

	for child in sorted:
		if "_interact" not in child: break
		print(child)
		child.parent._interaction()
		break

func _process(delta: float) -> void:
	valid_pool = []

	for interactor in get_tree().get_nodes_in_group("Interactor"):
		interactor.visible = interactor.global_position.distance_to(
			player.global_position
		) <= DISTANCE_THRESHOLD

		if interactor.visible:
			valid_pool.append(interactor)