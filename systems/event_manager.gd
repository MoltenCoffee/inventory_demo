extends Node

signal item_given(name: StringName, quantity: int)
signal item_given_in_slot(name: StringName, quantity: int, slot_id: int)
signal inventory_slot_emptied(slot_id: int)
signal inventory_slots_swapped(slot_index_a: int, slot_index_b: int)
signal inventory_emptied()
signal item_dropped(item_name: StringName, quantity: int, drop_position: Vector3)
signal item_picked(item_name: StringName, quantity: int, display_name: String)
signal hotbar_slot_selected(index: int)
signal item_throw_requested(slot_index: int, origin: Vector3, forward: Vector3)
