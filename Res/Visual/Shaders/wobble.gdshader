shader_type canvas_item;

uniform float amplitude: hint_range(0.0, 1.0);
uniform float speed: hint_range(0.0, 2.0);
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    COLOR = texture(screen_texture, SCREEN_UV);
}
void vertex() {
	// Called for every vertex the material is visible on.
	float time = TIME * (30. * speed);
	float wobbling = sin(time) * 40. * amplitude;
	float direction = sin(time / 2.);
	VERTEX += vec2(direction * wobbling,wobbling);
	//VERTEX += direction;
}