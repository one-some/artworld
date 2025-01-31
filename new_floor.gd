extends Control

@onready var crazed_label = $CrazedLabel

func _ready() -> void:
	show_floor_msg(1)

func show_floor_msg(floor_no: int) -> void:
	crazed_label.phrase = "floor %s" % floor_no
	crazed_label.hide_letters()
	$AnimationPlayer.play("reveal_floor")
	await $AnimationPlayer.animation_finished