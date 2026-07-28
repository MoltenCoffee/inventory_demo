shader_type canvas_item;

uniform sampler2D image: source_color, filter_nearest;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 tex_color = texture(image, UV);
	
	COLOR = vec4(color.rgb, tex_color.a * color.a);
}
