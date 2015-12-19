package;
import kha.math.Matrix3;
import kha.math.Vector2;

// Generates index and vertex data for a cylinder
class CylinderMesh {
	
	public var vertices: Array<Float>;
	public var indices: Array<Int>;
	
	public function new(sections : Int) {
		// Radius
		var r : Float = 0.5;
		// Height
		var h : Float = 1;
		
		vertices = new Array<Float>();
		indices = new Array<Int>();
		
		// Bottom center
		vertices.push(0);
		vertices.push(0);
		vertices.push(0);
		
		// Top center
		vertices.push(0);
		vertices.push(h);
		vertices.push(0);
		
		var index : Int = 2;
		var firstPoint : Vector2 = new Vector2(0, r);
		var lastPoint : Vector2 = firstPoint;
		var nextPoint : Vector2;
		for (i in 0...sections) {
			nextPoint = Matrix3.rotation(i * (2 / sections) * Math.PI).multvec(firstPoint);
			
			addSection(lastPoint, nextPoint, h, index);
			
			lastPoint = nextPoint;
			index += 4;
		}
		
		addSection(lastPoint, firstPoint, h, index);
		
		// Last part, close exactly (i.e. use first point)
		
		// Simple triangle
		/*vertices = [
		   -1.0, -1.0, 0.0,
			0.0, -1.0, 0.0,
			0.0,  0.0, r
		];
		indices = [
			0,
			1,
			2
		];*/
	}
	
	private function addSection(lastPoint : Vector2, nextPoint : Vector2, h : Float, index : Int) {
		vertices.push(lastPoint.x);
		vertices.push(0);
		vertices.push(lastPoint.y);
		
		vertices.push(lastPoint.x);
		vertices.push(h);
		vertices.push(lastPoint.y);
		
		vertices.push(nextPoint.x);
		vertices.push(0);
		vertices.push(nextPoint.y);
		
		vertices.push(nextPoint.x);
		vertices.push(h);
		vertices.push(nextPoint.y);
		
		// First part of side
		indices.push(index);
		indices.push(index + 1);
		indices.push(index + 2);
		
		// Second part of side
		indices.push(index + 3);
		indices.push(index + 2);
		indices.push(index + 1);
		
		// Bottom
		indices.push(0);
		indices.push(index);
		indices.push(index + 2);
		
		// Top
		indices.push(index + 3);
		indices.push(index + 1);
		indices.push(1);
	}
}