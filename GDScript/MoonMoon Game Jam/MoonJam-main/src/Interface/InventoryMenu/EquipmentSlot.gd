extends Panel

signal selected
signal unselected

const Equipment = preload("res://src/Nodes/Player/Equipment/Equipment.gd")

export(Equipment.SLOT) var slot

var equipment setget set_equipment
var selected: bool = false setget set_selected
var buyable: bool = false

onready var buy_panel = $BuyPanel
onready var texture_rect = $MarginContainer/Panel/TextureRect


func _ready() -> void:
	self.selected = false
	connect("focus_entered", self, "focus_entered")
	connect("focus_exited", self, "focus_exited")


func focus_entered() -> void:
	self.selected = true


func focus_exited() -> void:
	self.selected = false


func set_equipment(value: Equipment) -> void:
	equipment = value
	if !equipment:
		texture_rect.texture = null
	else:
		texture_rect.texture = equipment.texture


func set_selected(value: bool) -> void:
	selected = value
	if selected:
		if buyable:
			buy_panel.visible = true
		emit_signal("selected")
		var style = get("custom_styles/panel")
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_width_left = 4
		
		
		style.expand_margin_top = 3
		style.expand_margin_right = 3
		style.expand_margin_bottom = 3
		style.expand_margin_left = 3
		style.border_color = Color("#7F1D1D")
	else:
		buy_panel.visible = false
		emit_signal("unselected")
		var style = get("custom_styles/panel")
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_width_left = 1
		style.expand_margin_top = 0
		style.expand_margin_right = 0
		style.expand_margin_bottom = 0
		style.expand_margin_left = 0
		style.border_color = Color("#111111")
