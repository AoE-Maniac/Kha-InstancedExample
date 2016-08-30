# Kha-InstancedExample
Simple example for instanced rendering in Kha. Preview: http://www.aoe-maniac.de/instances/

Instanced rendering allows you to render an object multiple times with some variations, but in a singe drawcall. An example for this are lots of identical blocks with different positions. Rendering them individually there is lots of communication overhead between CPU and GPU. But please keep in mind that this only makes sense if you are drawing many instances of a single model.

There are 10.000 instances consiting of 128 polyons generated by default, both values can be tweaked easily.
