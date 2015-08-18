// Input vertex data, different for all executions of this shader
attribute vec3 pos;

attribute vec3 off;

void kore() {
	// Just output position
	gl_Position = vec4(pos + off, 1.0);
}