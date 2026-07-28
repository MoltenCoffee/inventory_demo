class_name InventorySlot
extends AspectRatioContainer

@onready var label: Label = %Count
@onready var icon: TextureRect = %TextureRect

@export var slot_id: int
var data: SlotData


func bind_data(new_data: SlotData) -> void:
	if data:
		data.updated.disconnect(update_visuals)
	
	data = new_data
	
	if data:
		data.updated.connect(update_visuals)
	
	update_visuals()


func update_visuals() -> void:
	if not data or data.is_empty():
		label.text = ""
		tooltip_text = ""
		icon.texture = null
		return
	
	var item := data.get_item()
	if not item:
		printerr("Couldn't render item '%s' in slot %d, item not found" % [data.item_name, slot_id])
		return
	
	tooltip_text = item.display_name
	label.text = str(data.quantity)
	icon.texture = item.icon


func _get_drag_data(_at_position: Vector2) -> Variant:
	if not data or data.is_empty():
		return null
	
	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(40, 40)
	
	var control := Control.new()
	control.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2.0
	
	set_drag_preview(control)
	return slot_id


func _can_drop_data(_at_position: Vector2, drag_data: Variant) -> bool:
	return typeof(drag_data) == TYPE_INT


func _drop_data(_at_position: Vector2, drag_data: Variant) -> void:
	EventManager.inventory_slots_swapped.emit(drag_data, slot_id)
