#ifdef GL_ES
precision mediump float;
#endif

varying vec3 fragmentColor;

void kore() {
	// Just output red color
	gl_FragColor = vec4(fragmentColor, 1.0);
}