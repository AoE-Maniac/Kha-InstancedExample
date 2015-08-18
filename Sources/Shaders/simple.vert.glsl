// Input vertex data, different for all executions of this shader
attribute vec3 pos;

attribute vec3 off;
attribute mat4 m;

void kore() {
	gl_Position = m * vec4((pos + off), 1.0);
}