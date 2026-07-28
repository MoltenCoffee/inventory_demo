class_name SlotData
extends Resource

signal updated()

@export var item_name := &""
@export var quantity := 0

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
