extends Control

const InventorySlotScene := preload("res://ui/inventory_slot.tscn")
const COLUMN_COUNT := 9

@export var inventory_row_count := 4
@export var inventory_data: InventoryData

@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var inventory_hotbar: GridContainer = %InventoryHotbar
@onready var clear_inventory_button: Button = %ClearInventoryButton

@export var hotbar_ui: Hotbar

func _ready() -> void:
	if not inventory_data:
		inventory_data = InventoryData.new()
		inventory_data.init_slots(COLUMN_COUNT + COLUMN_COUNT * inventory_row_count)
	
	if hotbar_ui:
		hotbar_ui.inventory_data = inventory_data
	
	build_ui()
	
	EventManager.inventory_emptied.connect(clear)
	EventManager.inventory_slot_emptied.connect(_on_slot_emptied)
	EventManager.item_given.connect(inventory_data.add_item)
	EventManager.inventory_slots_swapped.connect(_on_slots_swapped)
	EventManager.item_throw_requested.connect(_on_item_throw_requested)
	clear_inventory_button.pressed.connect(clear)


func build_ui() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()
	for child in inventory_hotbar.get_children():
		child.queue_free()
	
	for i in inventory_data.slots.size():
		var slot_ui := InventorySlotScene.instantiate()
		var slot_data := inventory_data.slots[i]
		
		slot_ui.slot_id = i
		
		if i < COLUMN_COUNT:
			inventory_hotbar.add_child(slot_ui)
		else:
			inventory_grid.add_child(slot_ui)
		
		slot_ui.bind_data(slot_data)


func clear() -> void:
	for slot_data in inventory_data.slots:
		slot_data.set_data(&"", 0)


func _on_slot_emptied(slot_id: int) -> void:
	if slot_id >= 0 and slot_id < inventory_data.slots.size():
		inventory_data.slots[slot_id].set_data(&"", 0)


func _on_slots_swapped(index_a: int, index_b: int) -> void:
	if index_a == index_b:
		return
		
	var slot_a := inventory_data.slots[index_a]
	var slot_b := inventory_data.slots[index_b]
	
	if slot_a.item_name == slot_b.item_name and not slot_a.is_empty():
		var item := slot_a.get_item()
		var max_stack := item.stack_size
		var total := slot_a.quantity + slot_b.quantity
		
		if total <= max_stack:
			slot_b.set_data(slot_b.item_name, total)
			slot_a.set_data(&"", 0)
		else:
			slot_b.set_data(slot_b.item_name, max_stack)
			slot_a.set_data(slot_a.item_name, total - max_stack)
		return
		
	var name_a := slot_a.item_name
	var qty_a := slot_a.quantity
	
	slot_a.set_data(slot_b.item_name, slot_b.quantity)
	slot_b.set_data(name_a, qty_a)


func _on_item_throw_requested(slot_index: int, origin: Vector3, forward: Vector3) -> void:
	var slot := inventory_data.slots[slot_index]
	if slot.is_empty():
		return
	
	var item_name := slot.item_name
	slot.set_data(item_name, slot.quantity - 1)
	
	var throw_pos := origin + forward * 1.5
	EventManager.item_dropped.emit(item_name, 1, throw_pos)
