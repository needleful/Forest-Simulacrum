shader_type canvas_item;
render_mode unshaded;

uniform vec4 color_light: hint_color;
uniform vec4 color_dark: hint_color;

 void fragment(){
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(mix(color_dark, color_light, c.r).rgb, c.a);
}