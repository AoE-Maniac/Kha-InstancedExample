package;
import kha.math.Matrix4;
import kha.math.Vector3;
import kha.Scheduler;

// Data container for cylinder instances
class Cylinder {
	
	private var yOffset : Float;
	private var position : Vector3;
	
	public function new(position : Vector3) {
		this.position = position;
	}
	
	public function getModelMatrix() : Matrix4 {
		return Matrix4.translation(position.x, position.y + yOffset, position.z);
	}
	
	public function update() {
		// Update position over time
		yOffset = Math.sin(position.x * 4 + position.z + Scheduler.time() * 2) / 4;
	}
}