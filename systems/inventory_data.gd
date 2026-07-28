class_name InventoryData
extends Resource

signal inventory_updated

@export var slots: Array[SlotData] = []

func init_slots(count: int) -> void:
	slots.clear()
	for i in count:
		slots.append(SlotData.new())
	inventory_updated.emit()


func add_item(item_name: StringName, quantity: int) -> int:
	var item := Items.get_item(item_name)
	if not item: 
		return quantity
	
	var remaining := quantity
	
	for slot in slots:
		if slot.item_name == item_name and not slot.is_full_stack():
			var space := item.stack_size - slot.quantity
			var added := mini(space, remaining)
			slot.set_data(item_name, slot.quantity + added)
			remaining -= added
			if remaining == 0: 
				return 0
			
	for slot in slots:
		if slot.is_empty():
			var added := mini(item.stack_size, remaining)
			slot.set_data(item_name, added)
			remaining -= added
			if remaining == 0: 
				return 0
			
	return remaining


func remove_item(slot_index: int, quantity: int) -> void:
	if slot_index < 0 or slot_index >= slots.size(): 
		return
		
	var slot := slots[slot_index]
	if slot.is_empty(): 
		return
	
	var new_quantity := slot.quantity - quantity
	if new_quantity <= 0:
		slot.set_data(&"", 0)
	else:
		slot.set_data(slot.item_name, new_quantity)


func swap_slots(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= slots.size() or index_b < 0 or index_b >= slots.size(): 
		return
	
	var slot_a := slots[index_a]
	var slot_b := slots[index_b]
	
	var temp_name := slot_a.item_name
	var temp_qty := slot_a.quantity
	
	slot_a.set_data(slot_b.item_name, slot_b.quantity)
	slot_b.set_data(temp_name, temp_qty)
