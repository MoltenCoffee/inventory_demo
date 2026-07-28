class_name ItemEntity
extends RigidBody3D

var quantity := 1
var item: Item

func _ready() -> void:
	if not item or not item.icon:
		queue_free()
		return

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = item.get_mesh()
	add_child(mesh_instance)
	
	var shape := BoxShape3D.new()
	var img_size := item.icon.get_size()
	shape.size = Vector3(
		img_size.x * item.pixel_size, 
		img_size.y * item.pixel_size, 
		item.pixel_size * item.thickness_pixels
	)
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = shape
	add_child(collision_shape)


func get_item_name() -> StringName:
	if not item:
		return &""
	return item.name


static func create(item_name, quantity) -> ItemEntity:
	var _item := Items.get_item(item_name)
	if not _item or not _item.icon:
		return null
	
	var entity := ItemEntity.new()
	entity.item = _item
	entity.quantity = quantity
	return entity
