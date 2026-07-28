class_name Hotbar
extends Control

@export var slot_scene: PackedScene
@export var inventory_data: InventoryData
@onready var container: HBoxContainer = $PanelContainer/MarginContainer/HBoxContainer

var slots: Array[InventorySlot] = []

func _ready() -> void:
	for i in 9:
		var slot := slot_scene.instantiate() as InventorySlot
		slot.slot_id = i
		container.add_child(slot)
		slots.append(slot)
		slot.bind_data(inventory_data.slots[i])
	
	EventManager.hotbar_slot_selected.connect(_on_slot_selected)


## Triggers on slot selection, changes the color of the selected to indicate selection
func _on_slot_selected(index: int) -> void:
	for i in slots.size():
		slots[i].modulate = Color(1.0, 1.0, 1.0, 1.0) if i != index else Color(1.0, 0.8, 0.2, 1.0)
