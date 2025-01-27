shader_type canvas_item;

uniform vec4 color_1: source_color = vec4(vec3(0.0), 1.0);
uniform sampler2D texture_1;
uniform bool use_texture = false;
uniform float thereshold: hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 color;
	if (use_texture) {
		color = texture(texture_1, UV);
	}
	else {
		color = color_1;
	}
	COLOR.rgb = color.rgb;
	COLOR.a = color.a * thereshold;
}
