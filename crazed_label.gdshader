shader_type canvas_item;

uniform float rand;
uniform float angle;
uniform float sq_half_size = 20.0;

void vertex() {
	float pn_little_rand = ((rand + 1.0) / 5.0) - 0.5;

	mat2 rotation = mat2(
		vec2(sin(angle) + (pn_little_rand), -cos(angle)),
		vec2(cos(angle), sin(angle))
	);

	VERTEX -= sq_half_size;
	VERTEX = VERTEX * rotation;
	VERTEX += sq_half_size;
}