let project = new Project('Instanced Example');

project.addSources('Sources');
project.addShaders('Sources/Shaders/**');

resolve(project);
