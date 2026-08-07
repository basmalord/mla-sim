shader_type canvas_item;

uniform float strength = 1.0;
uniform float manual_offset = 1.0;
uniform bool auto_scroll = false;
uniform sampler2D parallax_map : filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	float texels = float(textureSize(TEXTURE,0).x);
	float time = max(TIME*float(auto_scroll),1.0);
	float pixel_offset = floor(((1.0-texture(parallax_map,vec2(0,UV.y)).y) * time * manual_offset * strength) * texels);
	float uv_offset = pixel_offset / texels;
	vec2 new_uv = UV;
	new_uv.x += uv_offset;
	COLOR = texture(screen_texture, new_uv);
}