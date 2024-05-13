shader_type spatial;
render_mode unshaded, skip_vertex_transform, cull_disabled, depth_draw_never;

uniform float size_y = 0.5;
uniform vec3 color : source_color = vec3(1);
varying float height;
varying float vertical;
varying vec2 horizontal;

float random (vec2 st) {
    return fract(
		sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123
	);
}
float random3 (vec3 st) {
    return fract(
		sin(dot(st.xyz, vec3(12.9898, 78.233, 57.687))) * 43758.5453123
	);
}

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}
float noise3 (in vec3 st) {
    vec3 i = floor(st);
    vec3 f = fract(st);

    // Four corners in 2D of a tile
    float a = random3(i);
    float b = random3(i + vec3(1.0, 0.0, 0.0));
    float c = random3(i + vec3(0.0, 1.0, 0.0));
    float d = random3(i + vec3(1.0, 1.0, 0.0));
    float a2 = random3(i + vec3(0.0, 0.0, 1.0));
    float b2 = random3(i + vec3(1.0, 0.0, 1.0));
    float c2 = random3(i + vec3(0.0, 1.0, 1.0));
    float d2 = random3(i + vec3(1.0, 1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec3 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    float k = mix(a, b, u.x) + ((c - a) * (1.0 - u.x) + (d - b) * u.x) * u.y;
    float k2 = mix(a2, b2, u.x) + ((c2 - a2) * (1.0 - u.x) + (d2 - b2) * u.x) * u.y;
	return mix(k, k2, u.z);
}

void vertex() {
	height = VERTEX.y / size_y + .5;
	horizontal = VERTEX.xz;
	vertical = abs(NORMAL.y) < 0.01 ? 1.0 : 0.0;
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (vertical < 0.1) discard;
	vec2 scaled = horizontal * 25.0;
	float t = .50 * TIME;
	float r = noise3(vec3(scaled + vec2(0.5*t), t*0.05));
	r = min(r * 0.8 + 0.4, 1);
	float h = clamp(height / (r * r), 0, 1);
	float k = (h - 1.0) * (h - 1.0);
	ALPHA = k;//k*k*(3.0-2.0*k);
	ALBEDO = color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
