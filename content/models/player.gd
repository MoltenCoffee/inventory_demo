class_name Player
extends CharacterBody3D

## Player controller
##
## Although functional, this probably isn't the best example of a player controller out there.

const SPEED := 5.0
const SPRINT_SPEED := 8.5
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.005

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_range(1.0, 10.0, 0.1) var interaction_distance := 4.0 :
	get():
		return interaction_distance
	set(value):
		interaction_distance = value
		if interact_ray:
			interact_ray.target_position.y = -value
@export var default_crosshair_color := Color(1.0, 1.0, 1.0, 0.5)
@export var highlight_crosshair_color := Color(1.0, 0.5, 0.0, 0.5)

var is_inventory_open := false
var active_hotbar_index := -1

@onready var camera: Camera3D = $Camera3D
@onready var interact_ray: RayCast3D = $Camera3D/RayCast3D
@onready var crosshair: Crosshair = $HUD/Crosshair
@onready var inventory_ui: Control = $HUD/Inventory
@onready var message_label: Label = $HUD/MessageLabel
@onready var message_timer: Timer = $HUD/MessageTimer
@onready var hotbar: Hotbar = $HUD/Hotbar


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventManager.item_picked.connect(_on_item_picked)
	interact_ray.target_position.y = -interaction_distance
	message_timer.timeout.connect(clear_message)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if is_inventory_open:
		input_dir = Vector2.ZERO
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	_update_crosshair()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_open"):
		_toggle_inventory()
		
	if is_inventory_open:
		return
		
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if interact_ray.is_colliding():
					var collider := interact_ray.get_collider()
					if collider is ItemEntity:
						var item_name := (collider as ItemEntity).get_item_name()
						var item := Items.get_item(item_name)
						var display_name := item.display_name if item else String(item_name)
						
						EventManager.item_given.emit(item_name, collider.quantity)
						EventManager.item_picked.emit(item_name, collider.quantity, display_name)
						
						collider.queue_free()
			MOUSE_BUTTON_RIGHT:
				if active_hotbar_index != -1:
					var origin := camera.global_position
					var forward := -camera.global_transform.basis.z
					EventManager.item_throw_requested.emit(active_hotbar_index, origin, forward)
			MOUSE_BUTTON_WHEEL_UP:
				_change_hotbar_slot(-1)
			MOUSE_BUTTON_WHEEL_DOWN:
				_change_hotbar_slot(1)
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			_set_hotbar_slot(event.keycode - KEY_1)
		elif event.keycode == KEY_0:
			_set_hotbar_slot(-1)
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clampf(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func display_message(message: String, time := 5.0) -> void:
	message_label.text = message
	message_timer.start(time)


func clear_message() -> void:
	message_label.text = ""


func _toggle_inventory() -> void:
	is_inventory_open = !is_inventory_open
	inventory_ui.visible = is_inventory_open
	crosshair.visible = !is_inventory_open
	hotbar.visible = !is_inventory_open
	
	if is_inventory_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_item_picked(_item_name: StringName, quantity: int, display_name: String) -> void:
	display_message("Picked up %d items of %s" % [quantity, display_name])


func set_crosshair_color(color: Color) -> void:
	crosshair.color = color


func _update_crosshair() -> void:
	if is_inventory_open:
		return
		
	var is_looking_at_item := false
	
	if interact_ray.is_colliding():
		var collider := interact_ray.get_collider()
		if collider is ItemEntity:
			is_looking_at_item = true
			
	var target_color := highlight_crosshair_color if is_looking_at_item else default_crosshair_color
	set_crosshair_color(target_color)


func _change_hotbar_slot(dir: int) -> void:
	var new_index := active_hotbar_index + dir
	if new_index < 0:
		new_index = 8
	elif new_index > 8:
		new_index = 0
	_set_hotbar_slot(new_index)


func _set_hotbar_slot(index: int) -> void:
	active_hotbar_index = index
	EventManager.hotbar_slot_selected.emit(active_hotbar_index)
