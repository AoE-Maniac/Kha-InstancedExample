#ifdef GL_ES
precision mediump float;
#endif

// Input vertex data, different for all executions of this shader
attribute vec3 pos;

// Instanced input data (different for each instance but the same for each vertex of an instance)
attribute vec3 col;
attribute mat4 m;

// Output data - will be interpolated for each fragment
varying vec3 fragmentColor;

void kore() {
	gl_Position = m * vec4(pos, 1.0);
	fragmentColor = col;
}