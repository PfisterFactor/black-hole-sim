#define NUM_LAYERS 5.0

#define BLACKHOLE_RADIUS 0.1
#define BLACKHOLE_MASS 1.0
#define BACKGROUND_PLANE_DISTANCE 1.0

uniform vec2 resolution;
uniform int time;
in vec2 frag_position;

mat2 rotate(float angle) {
	float s = sin(angle);
	float c = cos(angle);

	mat2 rotateMatrix = mat2(c, -s, s, c);
	return rotateMatrix;
}

float CreateStar(vec2 uv, float flare) {
	float distanceFromCenter = length(uv);
	float star = 0.05 / distanceFromCenter;

	float rays = max(0.0, 1.0 - abs(uv.x * uv.y*500.0));
	rays *= flare;
	rays *= smoothstep(0.3,0.0,abs(uv.x));
    rays *= smoothstep(0.3,0.0,abs(uv.y));
	

	uv *= rotate(3.1415 / 4.0);
	float rotatedRays = max(0.0, 1.0 - abs(uv.x * uv.y*500.0));
	rotatedRays *= flare * 0.3;
	rotatedRays *= smoothstep(0.3,0.0,abs(uv.x));
    rotatedRays *= smoothstep(0.3,0.0,abs(uv.y));

	rays += rotatedRays;
	star += rays;
	star *= smoothstep(1.0, 0.2, distanceFromCenter);
	return star;
}

float Hash2to1(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec3 StarLayer(vec2 uv) {
	vec3 color = vec3(0);

	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv);

	for(int y = -1; y <= 1; y++) {
		for(int x = -1; x <= 1; x++) {
			vec2 offset = vec2(x, y);
			float n = Hash2to1(id + offset); // Random value between 0-1
			float size = fract(n * 3245.32);
			float star = CreateStar(gv - offset - (vec2(n, fract(n * 10.0)) - 0.5), smoothstep(0.9, 1.0, size));
			star *= sin(float(time)*0.005 + n*6.2831)*0.5+1.0;

			vec3 star_color = sin(vec3(0.2, 0.3, 0.9) * fract(n * 2343.212) * 4.0 * 3.148) * 0.5 + 0.5;
			star_color = star_color * vec3(1.0, 0.5, 1.0 + size);
			color += star * size * star_color;
		}
	}
	return color;
}
vec3 CreateStarBackground() {
	vec2 uv = (frag_position) / min(resolution.x, resolution.y);
	uv *= 3.0;

	float t = float(time) * 0.00005;

	vec3 col = vec3(0);
	for (float i = 0.0; i < 1.0; i+=1.0/NUM_LAYERS) {
		float depth = fract(i+t);
		float scale = mix(20.,0.5,depth);
		float fade = depth*smoothstep(1.0,0.9,depth);
		col += StarLayer(uv*scale+i*453.2)*fade;
	}
	
	
	return col;
}

// float BlackHoleAngleMap(float angleIn) {
// 	return -1.17996108*pow(angleIn,2) + 3.76272208*angleIn - 1.09216323;
// }
// void CreateBlackhole(vec3 background) {
// 	vec2 uv = (frag_position) / resolution.xy;
// 	float phi_x = asin(abs(uv.x)/BACKGROUND_PLANE_DISTANCE);
// 	float r_x = sqrt(pow(uv.x,2.0) + 1);
	
// 	float phi_y = asin(abs(uv.x)/BACKGROUND_PLANE_DISTANCE);
// 	float r_y = sqrt(pow(uv.y,2.0) + 1);
// }

void main() {
	vec3 background = CreateStarBackground();
	gl_FragColor = vec4(background,1.0);
}