extends RichTextLabel

@onready var player = Utils.from_group("Player")
@onready var og_pos = player.global_position

func _ready() -> void:
	self.visible = true
	show_soon()

func show_soon() -> void:
	self.modulate = Color.TRANSPARENT
	self.visible = true

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.0)
	tween.play()

func hide_now() -> void:
	if not visible: return
	await get_tree().create_timer(1.0).timeout

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.0)
	tween.play()

func _process(delta: float) -> void:
	if not self.visible: return
	if player.global_position == og_pos: return
	hide_now()
