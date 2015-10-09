package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;
import kha.Loader;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Program;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.Matrix4;

class Empty extends Game {
	// Simple triangle
	static var vertices: Array<Float> = [
	   -1.0, -1.0, 0.0,
	    0.0, -1.0, 0.0,
	   -0.5,  0.0, 0.0
	];
	static var indices: Array<Int> = [
		0,
		1,
		2
	];
	// Offsets for tree instances
	static var offsets: Array<Float> = [
		0.0, 0.0, 0.0,
		0.5, 1.0, 0.5,
		1.0, 0.0, 0.0
	];

	var vertexBuffers: Array<VertexBuffer>;
	var indexBuffer: IndexBuffer;
	var program: Program;

	public function new() {
		super("Empty");
	}

	override public function init() {
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
		
		var fragmentShader = new FragmentShader(Loader.the.getShader("simple.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("simple.vert"));
		
		vertexBuffers = new Array();
		// Vertex buffer
		vertexBuffers[0] = new VertexBuffer(
			Std.int(vertices.length / 3),
			structure,
			Usage.StaticUsage
		);
		
		var vbData = vertexBuffers[0].lock();
		for (i in 0...vbData.length) {
			vbData.set(i, vertices[i]);
		}
		vertexBuffers[0].unlock();
		
		// Index buffer
		indexBuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = indices[i];
		}
		indexBuffer.unlock();
		
		var instancedStructure = new VertexStructure();
        instancedStructure.add("off", VertexData.Float3);
		
		// Offset that is varied for each instance
		vertexBuffers[1] = new VertexBuffer(
			Std.int(vertices.length / 3),
			instancedStructure,
			Usage.StaticUsage,
			1 // instance data step rate
		);
		
		var oData = vertexBuffers[1].lock();
		for (i in 0...oData.length) {
			oData.set(i, offsets[i]);
		}
		vertexBuffers[1].unlock();
		
		program = new Program();
		program.setFragmentShader(fragmentShader);
		program.setVertexShader(vertexShader);
		program.link(structure, instancedStructure);
    }

	override public function render(frame:Framebuffer) {
		var g = frame.g4;
		
        g.begin();
		g.clear(Color.Black);
		g.setProgram(program);
		
		// Instanced rendering
		if (g.instancedRenderingAvailable()) {
			g.setVertexBuffers(vertexBuffers);
			g.setIndexBuffer(indexBuffer);
			g.drawIndexedVerticesInstanced(3);
		}
		else {
			// TODO: You should define an alternative as there might be older systems that do not support this extension!
		}
		
		// This is roughly the same as
		//for (i in 0...3) {
			//g.setFloat3(offID, offsets[i * 3], offsets[i * 3 + 1], offsets[i * 3 + 2]);
			//g.setVertexBuffer(vertexBuffer);
			//g.setIndexBuffer(indexBuffer);
			
			// g.drawIndexedVertices();
		//}
		
		g.end();
    }
}
