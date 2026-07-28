extends Node3D

@export var player_scene: PackedScene
@export var chunk_size := 32
@export var resolution := 16
@export var noise_scale := 5.0
@export var render_distance := 2

var noise := FastNoiseLite.new()
var chunks: Dictionary = {}
var player_node: Node3D
var current_player_chunk := Vector2(1000000, 1000000) # Arbitrary value to force initial update

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	EventManager.item_dropped.connect(_spawn_item_entity)
	_spawn_player()


func _process(_delta: float) -> void:
	if not player_node:
		return
		
	# Determine which chunk the player is currently standing in
	var player_chunk_pos := Vector2(
		floori(player_node.global_position.x / chunk_size),
		floori(player_node.global_position.z / chunk_size)
	)
	
	# Only update geometry if the player has entered a new chunk
	if player_chunk_pos != current_player_chunk:
		current_player_chunk = player_chunk_pos
		_update_chunks()


func _update_chunks() -> void:
	var expected_chunks := {}
	
	# 1. Map all chunks that should exist in the current radius
	for x in range(-render_distance, render_distance + 1):
		for z in range(-render_distance, render_distance + 1):
			expected_chunks[current_player_chunk + Vector2(x, z)] = true
			
	var chunks_to_remove: Array[Vector2] = []
	
	# 2. Identify and queue chunks for deletion if they are out of bounds
	for chunk_pos in chunks:
		if not expected_chunks.has(chunk_pos):
			chunks[chunk_pos].queue_free()
			chunks_to_remove.append(chunk_pos)
			
	# 3. Clean up the dictionary
	for pos in chunks_to_remove:
		chunks.erase(pos)
		
	# 4. Spawn missing chunks
	for chunk_pos in expected_chunks:
		_spawn_chunk(chunk_pos)


func _spawn_chunk(chunk_pos: Vector2) -> void:
	if chunks.has(chunk_pos):
		return
	
	var chunk := Chunk.new()
	chunk.position = Vector3(chunk_pos.x * chunk_size, 0, chunk_pos.y * chunk_size)
	
	add_child(chunk)
	chunk.generate(chunk_pos, chunk_size, resolution, noise_scale, noise)
	chunks[chunk_pos] = chunk

	if Items.items.size() > 0:
		var random_item_name := Items.get_random_item_name()
		
		var random_x := (chunk_pos.x * chunk_size) + randf_range(0.0, float(chunk_size))
		var random_z := (chunk_pos.y * chunk_size) + randf_range(0.0, float(chunk_size))
		var height := noise.get_noise_2d(random_x, random_z) * noise_scale
		
		_spawn_item_entity(random_item_name, 1, Vector3(random_x, height + 2.0, random_z))


func _spawn_player() -> void:
	if not player_scene:
		return
		
	var player := player_scene.instantiate() as CharacterBody3D
	add_child(player)
	
	var origin_height := noise.get_noise_2d(0, 0) * noise_scale
	player.global_position = Vector3(0, origin_height + 2.0, 0)
	
	player_node = player


func _spawn_item_entity(item_name: StringName, quantity: int, pos: Vector3) -> void:
	var entity := ItemEntity.create(item_name, quantity)
	entity.position = pos
	add_child(entity)
