extends Control


#var selected_equipment_slot = null
#var item_to_equip = null

const EquipmentSlot = preload("res://src/Interface/InventoryMenu/EquipmentSlot.tscn")

onready var done_button = $Menu/Inventory/VBoxContainer/DoneButton
onready var item_name_label = $Menu/Inventory/VBoxContainer/TitleBackground/MarginContainer/HBoxContainer/VBoxContainer/ItemNameLabel
onready var item_type_label = $Menu/Inventory/VBoxContainer/TitleBackground/MarginContainer/HBoxContainer/VBoxContainer/ItemTypeLabel
onready var item_description_label = $Menu/Inventory/VBoxContainer/ItemDescriptionLabel
onready var coin_label = $Menu/Inventory/VBoxContainer/TitleBackground/MarginContainer/CoinAmountContainer/CoinLabel

onready var title_bg = $Menu/Inventory/VBoxContainer/TitleBackground

onready var equipment_slot_container = $Menu/Inventory/VBoxContainer/EquipmentSlotContainer


onready var inventory = $Menu/Inventory
onready var no_items_label = $Menu/NoItemsInShopLabel

func _ready() -> void:
	get_tree().paused = true
	
	for slot in equipment_slot_container.get_children():
		slot.free()
	
	for item in Globals.shop_items:
		var equipment_slot = EquipmentSlot.instance()
		equipment_slot.slot = item.slot
		equipment_slot_container.add_child(equipment_slot)
		equipment_slot.equipment = item
		equipment_slot.buyable = true
	
	var slots = equipment_slot_container.get_children()
	
	for i in slots.size():
		var slot = slots[i]
		var previous_slot_index = posmod(i - 1, slots.size())
		var next_slot_index = posmod(i + 1, slots.size())
		var previous_slot = slots[previous_slot_index]
		var next_slot = slots[next_slot_index]
		
		slot.focus_neighbour_left = previous_slot.get_path()
		slot.focus_neighbour_right = next_slot.get_path()
		slot.focus_neighbour_bottom = done_button.get_path()
		
		slot.connect("mouse_entered", self, "_on_Slot_mouse_entered", [slot])
		slot.connect("gui_input", self, "_on_Slot_gui_input", [slot])
		slot.connect("selected", self, "_on_Slot_selected", [slot])
	
	if !slots.empty():
		slots[0].grab_focus()
		done_button.focus_neighbour_top = slots[0].get_path()
	else:
		title_bg.visible = false
		equipment_slot_container.visible = false
		item_description_label.visible = false
		
		no_items_label.visible = true
		done_button.grab_focus()
	
	
	done_button.connect("pressed", self, "_on_DoneButton_pressed")
	done_button.connect("mouse_entered", self, "_on_Slot_mouse_entered", [done_button])


func _process(delta: float) -> void:
	get_tree().paused = true


func _on_Slot_gui_input(event, slot_to_buy) -> void:
	if event.is_action_pressed("ui_accept"):
		var item = slot_to_buy.equipment
		if Globals.coins >= item.gold:
			Globals.coins -= item.gold
			Globals.available_items.append(item)
			Globals.shop_items.erase(item)
			
			Globals.save_data()
			slot_to_buy.queue_free()
			yield(slot_to_buy, "tree_exited")
			var slots = equipment_slot_container.get_children()
			for i in slots.size():
				var slot = slots[i]
				var previous_slot_index = posmod(i - 1, slots.size())
				var next_slot_index = posmod(i + 1, slots.size())
				var previous_slot = slots[previous_slot_index]
				var next_slot = slots[next_slot_index]
				
				slot.focus_neighbour_left = previous_slot.get_path()
				slot.focus_neighbour_right = next_slot.get_path()
				slot.focus_neighbour_bottom = done_button.get_path()
			
			
			if !slots.empty():
				slots[0].grab_focus()
				done_button.focus_neighbour_top = slots[0].get_path()
			else:
				title_bg.visible = false
				equipment_slot_container.visible = false
				item_description_label.visible = false
				no_items_label.visible = true
				done_button.grab_focus()


func _on_Slot_mouse_entered(slot) -> void:
	slot.grab_focus()


func _on_Slot_selected(slot) -> void:
	item_name_label.text = slot.equipment.name if slot.equipment else ""
	
	if slot.equipment.slot == Equipment.SLOT.ATTACK:
		item_type_label.text = "Attack"
	elif slot.equipment.slot == Equipment.SLOT.SPECIAL:
		item_type_label.text = "Special"
	elif slot.equipment.slot == Equipment.SLOT.PASSIVE:
		item_type_label.text = "Passive"
	
	coin_label.text = str(slot.equipment.gold)
	item_description_label.text = slot.equipment.description


func _on_DoneButton_pressed() -> void:
	#get_tree().paused = false
	visible = false
	#queue_free()
	var dialog = Dialogic.start("ShopEnd")
	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
	get_tree().root.add_child(dialog)
	
			#get_tree().paused = true
			
			#var dialog = Dialogic.start(dialog_timeline)
			#dialog.pause_mode = Node.PAUSE_MODE_PROCESS
			#dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
			#add_child(dialog)


func on_Dialog_timeline_end(timeline_name):
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	Events.emit_signal("game_resumed")
	free()
