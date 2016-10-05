package;
import kha.math.Matrix4;
import kha.math.Vector3;
import kha.Scheduler;

// Data container for cylinder instances
class Cylinder {
	
	private var amp : Float;
	private var phase : Float;
	private var yOffset : Float;
	private var position : Vector3;
	
	public function new(amp : Float, phase : Float, position : Vector3) {
		this.amp = amp;
		this.phase = phase;
		this.position = position;
	}
	
	public function getModelMatrix() : Matrix4 {
		return Matrix4.translation(position.x, position.y + yOffset, position.z);
	}
	
	public function update() {
		// Update position over time
		yOffset = amp * Math.sin(position.x * 4 + position.z + Scheduler.time() * 2 * phase) / 4;
	}
}