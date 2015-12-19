#ifdef GL_ES
precision mediump float;
#endif

varying vec3 fragmentColor;

void kore() {
	gl_FragColor = vec4(fragmentColor, 1.0);
}