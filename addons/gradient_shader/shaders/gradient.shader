shader_type spatial;
render_mode unshaded;

uniform vec4 color_light: hint_color;
uniform vec4 color_dark: hint_color;
uniform float noise_weight: hint_range(0.0,1.0);

uniform sampler2D noise;

uniform float y_top;
uniform float y_scale;

varying float gradient;

void vertex(){
	vec4 v = WORLD_MATRIX*vec4(VERTEX, 1);
	gradient = (y_top-v.y)/y_scale;
}

void fragment(){
	vec4 n = texture(noise,SCREEN_UV*6.0)* 2.0 - 1.0;
	float g = clamp(gradient + n.r*noise_weight, 0.0, 1.0);
	ALBEDO = mix(color_light, color_dark, g).rgb;
}