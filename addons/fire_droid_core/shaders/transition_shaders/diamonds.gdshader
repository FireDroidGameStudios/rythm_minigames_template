shader_type canvas_item;

// Ranges from 0 to 1 over the course of the transition.
// We use this to actually animate the shader.
uniform float progress : hint_range(0, 1);

// Size of each diamond, in pixels.
uniform float diamond_pixel_size = 10.0;

void fragment() {
	float x_fraction = fract(FRAGCOORD.x / diamond_pixel_size);
	float y_fraction = fract(FRAGCOORD.y / diamond_pixel_size);
	float x_distance = abs(x_fraction - 0.5);
	float y_distance = abs(y_fraction - 0.5);
	if (x_distance + y_distance + UV.x + UV.y > progress * 4.0) {
		discard;
	}
}