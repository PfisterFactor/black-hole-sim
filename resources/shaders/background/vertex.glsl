out vec2 frag_position;
void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
	frag_position = (modelViewMatrix * vec4(position, 1.0)).xy;
}