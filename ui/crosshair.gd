class_name Crosshair
extends Control

@onready var color_rect: ColorRect = $CenterContainer/ColorRect

@export var color := Color(1.0, 1.0, 1.0, 0.5) :
	get():
		return color
	set(value):
		color = value
		_set_color()


func _ready() -> void:
	# This is called in _ready as well as the color setter, because the color
	# could have been set when color_rect isn't ready yet.
	_set_color()


func _set_color() -> void:
	if color_rect:
		var mat: ShaderMaterial = color_rect.material
		mat.set_shader_parameter(&"color", color)
