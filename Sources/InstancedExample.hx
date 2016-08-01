package;

import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CullMode;
import kha.math.Random;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Scheduler;
import kha.Shaders;
import kha.Assets;
import kha.graphics4.CompareMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.math.Matrix4;

class InstancedExample {
	
	// Generate 100x100 instances
	static var instancesX = 100;
	static var instancesZ = 100;
	
	// Each cylinder has 32 sides generated, change to control level of detail / polygon count
	static var cylinderSections = 32; // Each section results in 4 polygons
	
	var cameraStart : Vector4;
	var view : Matrix4;
	var projection : Matrix4;
	var mvp : Matrix4;
	
	var instances : Array<Cylinder>;
	
	var vertexBuffers: Array<VertexBuffer>;
	var indexBuffer: IndexBuffer;
	var pipeline: PipelineState;

	public function new() {
		Random.init(Std.random(403));
		
		// Initialize data, not relevant for rendering
		instances = new Array<Cylinder>();
		for (x in 0...instancesX) {
			for (z in 0...instancesZ) {
				// Span x/z grid, center on 0/0
				var pos = new Vector3(x - (instancesX - 1) / 2, 0, z - (instancesZ - 1) / 2);
				instances.push(new Cylinder(pos));
			}
		}
		cameraStart = new Vector4(0, 5, 7.5);
		
		// Set up static projection matrix
		projection = Matrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		
		var structures = new Array<VertexStructure>();
		
		// Mesh structure, is shared by all instances
		var mesh : CylinderMesh = new CylinderMesh(cylinderSections);
		structures[0] = new VertexStructure();
        structures[0].add("pos", VertexData.Float3);
		
		// Vertex buffer
		vertexBuffers = new Array();
		vertexBuffers[0] = new VertexBuffer(
			Std.int(mesh.vertices.length / 3),
			structures[0],
			Usage.StaticUsage
		);
		
		var vbData = vertexBuffers[0].lock();
		for (i in 0...vbData.length) {
			vbData.set(i, mesh.vertices[i]);
		}
		vertexBuffers[0].unlock();
		
		// Index buffer
		indexBuffer = new IndexBuffer(
			mesh.indices.length,
			Usage.StaticUsage
		);
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = mesh.indices[i];
		}
		indexBuffer.unlock();
		
		// Color structure, is different for each instance
		structures[1] = new VertexStructure();
        structures[1].add("col", VertexData.Float3);
		
		vertexBuffers[1] = new VertexBuffer(
			instances.length,
			structures[1],
			Usage.StaticUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		
		var oData = vertexBuffers[1].lock();
		for (i in 0...instances.length) {
			oData.set(i * 3, 1);
			oData.set(i * 3 + 1, 0.75 + Random.getIn(-100, 100) / 500);
			oData.set(i * 3 + 2, 0);
		}
		vertexBuffers[1].unlock();
		
		// Transformation matrix, is different for each instance
		structures[2] = new VertexStructure();
		structures[2].add("m", VertexData.Float4x4);
		
		vertexBuffers[2] = new VertexBuffer(
			instances.length,
			structures[2],
			Usage.StaticUsage,
			1 // changed after every instance, use i higher number for repetitions
		);
		// Transformation matrix, buffer is not filled during initialization, but updated for each frame
		
		// Setup pipeline
		pipeline = new PipelineState();
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.inputLayout = structures;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = CullMode.CounterClockwise;
		pipeline.compile();
    }

	public function render(frame: Framebuffer) {
		var g = frame.g4;
		
		// Move camera and update view matrix
		var newCameraPos = Matrix4.rotationY(Scheduler.time() / 4).multvec(cameraStart);
		view = Matrix4.lookAt(new Vector3(newCameraPos.x, newCameraPos.y, newCameraPos.z), // Position in World Space
			new Vector3(0, 0, 0), // Looks at the origin
			new Vector3(0, 1, 0) // Up-vector
		);
		
		var vp = Matrix4.identity();
		vp = vp.multmat(projection);
		vp = vp.multmat(view);
		
		// Fill transformation matrix buffer with values from each instance
		var mData = vertexBuffers[2].lock();
		for (i in 0...instances.length) {
			mvp = vp.multmat(instances[i].getModelMatrix());
			
			mData.set(i * 16 + 0, mvp._00);		
			mData.set(i * 16 + 1, mvp._01);		
			mData.set(i * 16 + 2, mvp._02);		
			mData.set(i * 16 + 3, mvp._03);		
			
			mData.set(i * 16 + 4, mvp._10);		
			mData.set(i * 16 + 5, mvp._11);		
			mData.set(i * 16 + 6, mvp._12);		
			mData.set(i * 16 + 7, mvp._13);		
			
			mData.set(i * 16 + 8, mvp._20);		
			mData.set(i * 16 + 9, mvp._21);		
			mData.set(i * 16 + 10, mvp._22);		
			mData.set(i * 16 + 11, mvp._23);		
			
			mData.set(i * 16 + 12, mvp._30);		
			mData.set(i * 16 + 13, mvp._31);		
			mData.set(i * 16 + 14, mvp._32);		
			mData.set(i * 16 + 15, mvp._33);		
		}		
		vertexBuffers[2].unlock();
		
        g.begin();
		g.clear(Color.fromFloats(1, 0.75, 0));
		g.setPipeline(pipeline);
		
		// Instanced rendering
		if (g.instancedRenderingAvailable()) {
			g.setVertexBuffers(vertexBuffers);
			g.setIndexBuffer(indexBuffer);
			g.drawIndexedVerticesInstanced(instances.length);
		}
		else {
			// TODO: You should define an alternative as there might be older systems that do not support this extension!
			//for (i in 0...3) {
				//g.setFloat3(col, ...);
				//g.setMatrix(m, ...);
				//g.setVertexBuffer(vertexBuffer);
				//g.setIndexBuffer(indexBuffer);
				
				// g.drawIndexedVertices();
			//}
		}
		
		g.end();
    }
	
	public function update() {
		// Updated cylinders
		for (i in 0...instances.length) {
			instances[i].update();
		}
	}
}
