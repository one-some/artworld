@tool
extends Control

@export var phrase: String = "":
	set (value):
		phrase = value
		process_phrase(value)
	get:
		return phrase

const shader_mat = preload("res://crazed_letter_shader.tres")
const fonts = [
	preload("res://MS Gothic.ttf"),
	preload("res://Bethany Elingston.otf"),
]

func _ready() -> void:
	create("Floor ONE")
	$Panel.visible = false

func process_phrase(phrase: String):
	for child in self.get_children():
		if child.name == "Panel": continue

func create(text: String):
	seed(text.hash())
	
	var x_px = 0
	for c in text.to_lower():
		if randf() < 0.5:
			c = c.to_upper()
		
		if c == " ":
			x_px += 20.0
			continue
		
		
		var label = Label.new()
		label.scale = Vector2(0.5, 0.5)
		label.position.x = x_px
		x_px += randf_range(17.0, 20.0)
		self.add_child(label)
		label.use_parent_material = true
		
		var text_black = randf() < 0.4
		
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color.WHITE if text_black else Color.BLACK
		stylebox.border_width_bottom = randi_range(1, 3)
		stylebox.border_width_top = randi_range(1, 3)
		stylebox.border_width_left = randi_range(1, 3)
		stylebox.border_width_right = randi_range(1, 3)
		stylebox.border_color = Color.BLACK if text_black else Color.WHITE
		
		label.add_theme_stylebox_override("normal", stylebox)
		label.label_settings = LabelSettings.new()
		label.label_settings.font_color = Color.BLACK if text_black else Color.WHITE
		label.label_settings.font_size = randi_range(20, 48)
		
		var font = FontVariation.new()
		font.variation_embolden = randf_range(0.1, 0.6)
		font.variation_transform.x.x += randf() / 6.0
		font.base_font = fonts.pick_random()
		label.label_settings.font = font
		
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = font.get_string_size(c) * randf_range(2.0, 3.0)
		label.material = shader_mat.duplicate()
		label.material.set_shader_parameter("rand", randf())
		label.rotation += randf_range(-0.2, 0.2)
		label.pivot_offset = label.size / 2.0
		#label.material.set_shader_parameter("angle", randf_range(1.2, 1.9))
		label.text = c

	
	randomize()
