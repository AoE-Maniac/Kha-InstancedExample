#version 450

// Input vertex data, different for all executions of this shader
in vec3 pos;

// Instanced input data (different for each instance but the same for each vertex of an instance)
in vec3 col;
in mat4 m;

// Output data - will be interpolated for each fragment
out vec3 fragmentColor;

void main() {
	gl_Position = m * vec4(pos, 1.0);
	fragmentColor = col;
}