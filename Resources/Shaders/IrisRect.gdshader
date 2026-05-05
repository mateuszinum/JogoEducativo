shader_type canvas_item;

uniform float circle_size : hint_range(0.0, 1.05) = 1.05;

void fragment() {
	float ratio = (1.0 / SCREEN_PIXEL_SIZE.x) / (1.0 / SCREEN_PIXEL_SIZE.y);
	vec2 uv = UV;
	uv.x *= ratio;
	vec2 center = vec2(0.5 * ratio, 0.5);
	
	float length_dist = length(uv - center);
	float alpha = smoothstep(circle_size - 0.01, circle_size, length_dist);
	
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}