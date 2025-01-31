extends RichTextLabel

@onready var player = Utils.from_group("Player")

func _ready() -> void:
	self.visible = false

func show_soon() -> void:
	self.modulate = Color.TRANSPARENT
	self.visible = true

	await get_tree().create_timer(3.0).timeout
	if $"..".flung: return

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.0)
	tween.play()

func hide_now() -> void:
	if not visible: return
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
	tween.play()

func _process(delta: float) -> void:
	if self.visible: return
	if player.global_position.distance_to(self.global_position) > 100: return
	show_soon()
