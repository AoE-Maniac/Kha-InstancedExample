#version 450

in vec3 fragmentColor;
out vec4 frag;

void main() {
	frag = vec4(fragmentColor, 1.0);
}