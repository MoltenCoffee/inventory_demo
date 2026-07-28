class_name Chunk
extends StaticBody3D

var material: ShaderMaterial = preload("res://content/models/terrain.tres")
var collision_shape: CollisionShape3D
var mesh_instance: MeshInstance3D

func _init() -> void:
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)


func generate(chunk_pos: Vector2, chunk_size: int, resolution: int, noise_scale: float, noise: FastNoiseLite) -> void:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var step := float(chunk_size) / resolution
	var offset_x := chunk_pos.x * float(chunk_size)
	var offset_z := chunk_pos.y * float(chunk_size)
	
	for z in resolution + 1:
		for x in resolution + 1:
			var world_x := offset_x + x * step
			var world_z := offset_z + z * step
			var y := noise.get_noise_2d(world_x, world_z) * noise_scale

			var height_left := noise.get_noise_2d(world_x - step, world_z) * noise_scale
			var height_right := noise.get_noise_2d(world_x + step, world_z) * noise_scale
			var height_up := noise.get_noise_2d(world_x, world_z - step) * noise_scale
			var height_down := noise.get_noise_2d(world_x, world_z + step) * noise_scale

			var normal := Vector3(height_left - height_right, 2.0 * step, height_up - height_down).normalized()

			surface_tool.set_normal(normal)
			surface_tool.set_uv(Vector2(world_x, world_z))
			surface_tool.add_vertex(Vector3(x * step, y, z * step))

	for z in resolution:
		for x in resolution:
			var i := x + z * (resolution + 1)
			
			surface_tool.add_index(i)
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + resolution + 1)
			
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + resolution + 2)
			surface_tool.add_index(i + resolution + 1)

	surface_tool.generate_tangents()
	
	var mesh := surface_tool.commit()
	mesh.surface_set_material(0, material)
	mesh_instance.mesh = mesh
	collision_shape.shape = mesh.create_trimesh_shape()
