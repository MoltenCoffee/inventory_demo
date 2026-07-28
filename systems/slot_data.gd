class_name SlotData
extends Resource

signal updated()

@export var item_name := &""
@export var quantity := 0

static func create(item_name: StringName, quantity: int) -> SlotData:
	var slot := SlotData.new()
	slot.set_data(item_name, quantity)
	return slot


static func from_dict(dict: Dictionary) -> SlotData:
	if not dict.has_all(["item_name", "quantity"]):
		printerr("Missing required keys for SlotData")
		return null

	var item_name = dict.get("item_name")
	if not typeof(item_name) == Variant.Type.TYPE_STRING:
		printerr("Wrong type for item_name in SlotData")
	var quantity = dict.get("quantity")
	if not typeof(quantity) == Variant.Type.TYPE_INT:
		printerr("Wrong type for quantity in SlotData")

	var slot_data := SlotData.new()
	slot_data.item_name = dict["item_name"]
	slot_data.quantity = dict["quantity"]
	return slot_data


func set_data(new_item_name: StringName, new_quantity: int) -> void:
	item_name = new_item_name
	quantity = new_quantity
	updated.emit()


func clear() -> void:
	item_name = &""
	quantity = 0


func get_item() -> Item: # or null
	return Items.get_item(item_name)


func is_empty() -> bool:
	return quantity <= 0 or item_name.is_empty()


func is_full_stack() -> bool:
	var item := get_item()
	if not item:
		return false
	return quantity == item.stack_size


func to_dict() -> Dictionary:
	var dict := {
		"item_name": item_name,
		"quantity": quantity,
	}
	return dict
