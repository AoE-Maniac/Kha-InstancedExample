package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;
import kha.graphics4.ArrayBuffer;
import kha.graphics4.AttributeLocation;
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
	static var vertices:Array<Float> = [
	   -1.0, -1.0, 0.0,
	    0.0, -1.0, 0.0,
	   -0.5,  0.0, 0.0
	];
	static var indices:Array<Int> = [
		0,
		1,
		2
	];
	// Offsets for tree instances
	static var offsets:Array<Float> = [
		0.0, 0.0, 0.0,
		0.5, 1.0, 0.5,
		1.0, 0.0, 0.0
	];

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var offsetBuffer:ArrayBuffer;
	var mBuffer:ArrayBuffer;
	var program:Program;
	var offID:AttributeLocation;
	var mID:AttributeLocation;

	public function new() {
		super("Empty");
	}

	override public function init() {
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
		
		var fragmentShader = new FragmentShader(Loader.the.getShader("simple.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("simple.vert"));
		
		program = new Program();
		program.setFragmentShader(fragmentShader);
		program.setVertexShader(vertexShader);
		program.link(structure);

		// Vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(vertices.length / 3),
			structure,
			Usage.StaticUsage
		);
		
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, vertices[i]);
		}
		vertexBuffer.unlock();
		
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
		
		// Offset that is varied for each instance
		offsetBuffer = new ArrayBuffer(
			offsets.length,
			3, // Vec3
			1,
			Usage.StaticUsage
		);
		
		var oData = offsetBuffer.lock();
		for (i in 0...oData.length) {
			oData[i] = offsets[i];
		}
		offsetBuffer.unlock();
		
		// Matrix for transformations
		mBuffer = new ArrayBuffer(
			3 * 4 * 4, // 3 * 4x4
			4, // Vec4
			4, // * 4 (there are no matrix primitives for glVertexAttribPointer)
			Usage.StaticUsage
		);
		
		var mData = mBuffer.lock();
		var m : Matrix4;
		for (i in 0...3) {
			m = Matrix4.rotationZ(Math.PI * 0.5);
			mData[i * 16 + 0] = m._00;
			mData[i * 16 + 1] = m._01;
			mData[i * 16 + 2] = m._02;
			mData[i * 16 + 3] = m._03;
			
			mData[i * 16 + 4] = m._10;
			mData[i * 16 + 5] = m._11;
			mData[i * 16 + 6] = m._12;
			mData[i * 16 + 7] = m._13;
			
			mData[i * 16 + 8] = m._20;
			mData[i * 16 + 9] = m._21;
			mData[i * 16 + 10] = m._22;
			mData[i * 16 + 11] = m._23;
			
			mData[i * 16 + 12] = m._30;
			mData[i * 16 + 13] = m._31;
			mData[i * 16 + 14] = m._32;
			mData[i * 16 + 15] = m._33;
		}
		mBuffer.unlock();
		
		offID = program.getAttributeLocation("off"); // Attribute location since it is changed during shader calls
		mID = program.getAttributeLocation("m");
    }

	override public function render(frame:Framebuffer) {
		var g = frame.g4;
		
        g.begin();
		g.clear(Color.Black);
		g.setProgram(program);
		
		// Instanced rendering
		if (g.instancedRenderingAvailable()) {
			offsetBuffer.set(offID, 1); // Divisor is 1, i.e. offset changes after each instance is drawn
			mBuffer.set(mID, 1); // Divisor is 1, i.e. offset changes after each instance is drawn
			
			g.setVertexBuffer(vertexBuffer);
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