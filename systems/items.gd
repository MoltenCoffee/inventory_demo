extends Node

const ITEM_DIR := "res://content/items/"
const ICON_DIR := "res://content/icons/"
var items: Dictionary[StringName, Item]

func _init() -> void:
	# Preconfigured resources
	items.set(&"pencil", load(ITEM_DIR.path_join("pencil.tres")))
	items.set(&"snowflake", load(ITEM_DIR.path_join("snowflake.tres")))
	items.set(&"gem", load(ITEM_DIR.path_join("gem.tres")))
	
	# or dynamically created:
	var calendar := Item.new()
	calendar.icon = load(ICON_DIR.path_join("calendar.png"))
	calendar.name = &"calendar"
	calendar.display_name = "Calendar"
	calendar.stack_size = 6
	calendar.weight = 0.6
	items.set(calendar.name, calendar)
	
	# or dynamically created from data:
	var items_json_path := ITEM_DIR.path_join("items.json")
	if FileAccess.file_exists(items_json_path):
		var items_json := FileAccess.get_file_as_string(items_json_path)
		var items_data: Variant = JSON.parse_string(items_json)
		if items_data == null:
			printerr("Failed to parse items JSON")
		elif typeof(items_data) == Variant.Type.TYPE_ARRAY:
			for raw_item in items_data:
				if not typeof(raw_item) == Variant.Type.TYPE_DICTIONARY:
					printerr("Invalid type for item")
					continue
				var item_dict: Dictionary = raw_item
				if not item_dict.has_all(["name", "icon"]):
					printerr("Required keys missing for item")
					continue
				var item_name = item_dict.get("name")
				if not typeof(item_name) == Variant.Type.TYPE_STRING:
					printerr("Wrong type for item name")
					continue
				var item_icon = item_dict.get("icon")
				if not typeof(item_name) == Variant.Type.TYPE_STRING:
					printerr("Wrong type for item icon")
					continue
				if not FileAccess.file_exists(ICON_DIR.path_join(item_icon)):
					printerr("Icon '%s' not found in item directory" % item_icon)
					continue
				
				var item := Item.new()
				item.name = item_name
				item.icon = load(ICON_DIR.path_join(item_icon))
				
				# Optional parameters
				item.display_name = item_name
				if item_dict.has("display_name"):
					var item_display_name = item_dict["display_name"]
					if typeof(item_display_name) != Variant.Type.TYPE_STRING:
						push_warning("Invalid type for 'display_name' of item '%s'" % item_name)
					else:
						item.display_name = item_display_name
				if item_dict.has("weight"):
					var item_weight = item_dict["weight"]
					if typeof(item_weight) != Variant.Type.TYPE_FLOAT and typeof(item_weight) != Variant.Type.TYPE_INT:
						push_warning("Invalid type for 'weight' of item '%s'" % item_name)
					else:
						item.weight = item_weight
				if item_dict.has("stack_size"):
					var item_stack_size = item_dict["stack_size"]
					if typeof(item_stack_size) != Variant.Type.TYPE_INT and typeof(item_stack_size) != Variant.Type.TYPE_FLOAT:
						push_warning("Invalid type '%s' for key 'stack_size' of item '%s'" % [type_string(typeof(item_stack_size)), item_name])
					else:
						item_stack_size = floor(item_stack_size)
				items.set(item.name, item)


func get_item(item_name: StringName) -> Item:
	return items.get(item_name)


func has_item(item_name: StringName) -> bool:
	return items.has(item_name)


func get_item_count() -> int:
	return items.size()


func get_random_item_name() -> StringName:
	var keys: Array[StringName] = items.keys()
	return keys.pick_random()


func get_random_item() -> Item:
	return items[get_random_item_name()]
