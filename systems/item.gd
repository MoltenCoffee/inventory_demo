class_name Item
extends Resource

@export var icon := preload("res://icon.svg")
@export var name := &"item"
@export_range(1, 128) var stack_size := 64
@export var weight := 10.0
@export var display_name := ""

@export var pixel_size := 0.05
@export var thickness_pixels := 1.0
var mesh: Mesh


## Returns a 3D mesh of the item, built from the icon.
func get_mesh() -> Mesh:
	if not icon:
		printerr("Can't build mesh for item '%s' with missing icon" % name)
		return null
	_build_mesh()
	return mesh

## This is a long and complex method takes the icon file and creates a 3D meshe from it. This is probably overkill.
## FIXME: from some angles, the mesh is see through. Possibly a winding issue.
func _build_mesh() -> void:
	if mesh: return
	
	var image := icon.get_image()
	var width := image.get_width()
	var height := image.get_height()
	
	var grid := PackedByteArray()
	grid.resize(width * height)
	grid.fill(0)
	
	for y in height:
		for x in width:
			if image.get_pixel(x, y).a > 0.5:
				grid[y * width + x] = 1
				
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var offset_x := width / 2.0
	var offset_y := height / 2.0
	var z_half := (pixel_size * thickness_pixels) / 2.0
	
	var add_quad = func(p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, normal: Vector3) -> void:
		st.set_normal(normal)
		st.add_vertex(p1)
		st.add_vertex(p2)
		st.add_vertex(p3)
		st.set_normal(normal)
		st.add_vertex(p1)
		st.add_vertex(p3)
		st.add_vertex(p4)
		
	var visited := grid.duplicate()
	
	for y in height:
		for x in width:
			if visited[y * width + x] == 1:
				var w := 1
				while x + w < width and visited[y * width + (x + w)] == 1:
					w += 1
					
				var h := 1
				var done := false
				while y + h < height:
					for k in w:
						if visited[(y + h) * width + (x + k)] == 0:
							done = true
							break
					if done: break
					h += 1
					
				for dy in h:
					for dx in w:
						visited[(y + dy) * width + (x + dx)] = 0
						
				var x0 := (x - offset_x) * pixel_size
				var x1 := (x + w - offset_x) * pixel_size
				var y0 := -(y - offset_y) * pixel_size
				var y1 := -(y + h - offset_y) * pixel_size
				
				add_quad.call(
					Vector3(x0, y0, z_half), Vector3(x1, y0, z_half), 
					Vector3(x1, y1, z_half), Vector3(x0, y1, z_half), Vector3(0, 0, 1))
				add_quad.call(
					Vector3(x1, y0, -z_half), Vector3(x0, y0, -z_half), 
					Vector3(x0, y1, -z_half), Vector3(x1, y1, -z_half), Vector3(0, 0, -1))
					
	for y in height:
		var current_top_x := -1
		var current_bot_x := -1
		
		for x in width + 1:
			var is_solid := x < width and grid[y * width + x] == 1
			var up_empty := y == 0 or (x < width and grid[(y - 1) * width + x] == 0)
			var down_empty := y == height - 1 or (x < width and grid[(y + 1) * width + x] == 0)
			
			if is_solid and up_empty:
				if current_top_x == -1: current_top_x = x
			elif current_top_x != -1:
				var x0 := (current_top_x - offset_x) * pixel_size
				var x1 := (x - offset_x) * pixel_size
				var y0 := -(y - offset_y) * pixel_size
				add_quad.call(
					Vector3(x0, y0, -z_half), Vector3(x1, y0, -z_half),
					Vector3(x1, y0, z_half), Vector3(x0, y0, z_half), Vector3(0, 1, 0))
				current_top_x = -1
				
			if is_solid and down_empty:
				if current_bot_x == -1: current_bot_x = x
			elif current_bot_x != -1:
				var x0 := (current_bot_x - offset_x) * pixel_size
				var x1 := (x - offset_x) * pixel_size
				var y1 := -(y + 1 - offset_y) * pixel_size
				add_quad.call(
					Vector3(x0, y1, z_half), Vector3(x1, y1, z_half),
					Vector3(x1, y1, -z_half), Vector3(x0, y1, -z_half), Vector3(0, -1, 0))
				current_bot_x = -1
				
	for x in width:
		var current_left_y := -1
		var current_right_y := -1
		
		for y in height + 1:
			var is_solid := y < height and grid[y * width + x] == 1
			var left_empty := x == 0 or (y < height and grid[y * width + (x - 1)] == 0)
			var right_empty := x == width - 1 or (y < height and grid[y * width + (x + 1)] == 0)
			
			if is_solid and left_empty:
				if current_left_y == -1: current_left_y = y
			elif current_left_y != -1:
				var y0 := -(current_left_y - offset_y) * pixel_size
				var y1 := -(y - offset_y) * pixel_size
				var x0 := (x - offset_x) * pixel_size
				add_quad.call(
					Vector3(x0, y0, z_half), Vector3(x0, y0, -z_half),
					Vector3(x0, y1, -z_half), Vector3(x0, y1, z_half), Vector3(-1, 0, 0))
				current_left_y = -1
				
			if is_solid and right_empty:
				if current_right_y == -1: current_right_y = y
			elif current_right_y != -1:
				var y0 := -(current_right_y - offset_y) * pixel_size
				var y1 := -(y - offset_y) * pixel_size
				var x1 := (x + 1 - offset_x) * pixel_size
				add_quad.call(
					Vector3(x1, y0, -z_half), Vector3(x1, y0, z_half),
					Vector3(x1, y1, z_half), Vector3(x1, y1, -z_half), Vector3(1, 0, 0))
				current_right_y = -1
				
	st.index()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.BLACK
	st.set_material(mat)
	mesh = st.commit()
