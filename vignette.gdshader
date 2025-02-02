shader_type canvas_item;

// https://godotshaders.com/shader/vignette-3/


uniform float outer_radius : hint_range(0.0, 30.0) = 1.0;
uniform float main_alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 vignette_color: source_color;

void fragment() {
	float x = abs(UV.x - 0.5) * 2.0;
	float y = abs(UV.y - 0.5) * 2.0;
	float v = (sqrt((x * x) + (y * y)) / outer_radius);
	COLOR = vec4(vignette_color.rgb, v * main_alpha * COLOR.a);
}