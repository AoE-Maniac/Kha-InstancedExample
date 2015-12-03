package;

import kha.Framebuffer;
import kha.Color;
import kha.Shaders;
import kha.Assets;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.Matrix4;

class Empty {
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
	var pipeline: PipelineState;

	public function new() {
		var structures = new Array<VertexStructure>();
		structures[0] = new VertexStructure();
        structures[0].add("pos", VertexData.Float3);
		
		vertexBuffers = new Array();
		// Vertex buffer
		vertexBuffers[0] = new VertexBuffer(
			Std.int(vertices.length / 3),
			structures[0],
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
		
		structures[1] = new VertexStructure();
        structures[1].add("off", VertexData.Float3);
		
		// Offset that is varied for each instance
		vertexBuffers[1] = new VertexBuffer(
			Std.int(vertices.length / 3),
			structures[1],
			Usage.StaticUsage,
			1 // instance data step rate
		);
		
		var oData = vertexBuffers[1].lock();
		for (i in 0...oData.length) {
			oData.set(i, offsets[i]);
		}
		vertexBuffers[1].unlock();
		
		pipeline = new PipelineState();
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.inputLayout = structures;
		pipeline.compile();
    }

	public function render(frame:Framebuffer) {
		var g = frame.g4;
		
        g.begin();
		g.clear(Color.Black);
		g.setPipeline(pipeline);
		
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
