shader_type spatial;

uniform sampler2D noise_texture;
uniform vec4 color_base : source_color = vec4(0.18, 0.40, 0.15, 1.0);
uniform vec4 color_tint : source_color = vec4(0.25, 0.48, 0.20, 1.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);

void fragment() {
	float noise_val = texture(noise_texture, UV * uv_scale).r;
	ALBEDO = mix(color_base.rgb, color_tint.rgb, noise_val);
}
