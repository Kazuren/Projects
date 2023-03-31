extends Control


#var selected_equipment_slot = null
#var item_to_equip = null

const EquipmentSlot = preload("res://src/Interface/InventoryMenu/EquipmentSlot.tscn")

onready var done_button = $Menu/Inventory/VBoxContainer/DoneButton
onready var item_name_label = $Menu/Inventory/VBoxContainer/TitleBackground/VBoxContainer/ItemLabel
onready var item_description_label = $Menu/Inventory/VBoxContainer/ItemDescriptionLabel
onready var item_type_label = $Menu/Inventory/VBoxContainer/TitleBackground/VBoxContainer/ItemTypeLabel

onready var inventory = $Menu/Inventory
onready var equipment_slot_container = $Menu/Inventory/VBoxContainer/EquipmentSlotContainer

onready var select_item_menu = $Menu/SelectItemMenu
onready var not_equipped_slot_container = $Menu/SelectItemMenu/VBoxContainer/EquipmentSlotContainer


onready var select_item_menu_item_label = $Menu/SelectItemMenu/VBoxContainer/TitleBackground/VBoxContainer/ItemLabel
onready var select_item_menu_item_label_background = $Menu/SelectItemMenu/VBoxContainer/TitleBackground
onready var select_item_menu_done_button = $Menu/SelectItemMenu/VBoxContainer/DoneButton
onready var select_item_menu_item_type_label = $Menu/SelectItemMenu/VBoxContainer/TitleBackground/VBoxContainer/ItemTypeLabel
onready var select_item_menu_item_description_label = $Menu/SelectItemMenu/VBoxContainer/ItemDescriptionLabel

onready var no_items_label = $Menu/SelectItemMenu/NoItemsLabel


func _ready() -> void:
	get_tree().paused = true
	
	var equipment_slots = equipment_slot_container.get_children()
	
	for i in equipment_slots.size():
		var slot = equipment_slots[i]
		slot.equipment = Globals.equipped_items[i]
		slot.connect("mouse_entered", self, "_on_Slot_mouse_entered", [slot])
		slot.connect("gui_input", self, "_on_Slot_gui_input", [slot])
		#slot.connect("mouse_exited", self, "_on_Slot_mouse_exited", [slot])
		slot.connect("selected", self, "_on_Slot_selected", [slot])
		#slot.connect("unselected", self, "_on_Slot_unselected", [slot])
	
	#var not_equipped_slots = not_equipped_slot_container.get_children()
	#for slot in 
	
	equipment_slots[0].grab_focus()
	
	done_button.connect("pressed", self, "_on_DoneButton_pressed")
	done_button.connect("mouse_entered", self, "_on_Slot_mouse_entered", [done_button])
	
	select_item_menu_done_button.connect("mouse_entered", self, "_on_Slot_mouse_entered", [select_item_menu_done_button])


func _process(delta: float) -> void:
	get_tree().paused = true


func _on_Slot_gui_input(event, slot_to_change) -> void:
	if event.is_action_pressed("ui_accept"):
		slot_to_change.release_focus()
		inventory.visible = false
		select_item_menu.visible = true
		
		for slot in not_equipped_slot_container.get_children():
			slot.free()
		
		for item in Globals.available_items:
			if item.slot == slot_to_change.slot:
				var equipment_slot = EquipmentSlot.instance()
				equipment_slot.slot = item.slot
				not_equipped_slot_container.add_child(equipment_slot)
				equipment_slot.equipment = item
		
		if not_equipped_slot_container.get_child_count() == 0:
			no_items_label.visible = true
			select_item_menu_item_label_background.visible = false
			select_item_menu_item_description_label.visible = false
		else:
			no_items_label.visible = false
			select_item_menu_item_label_background.visible = true
			select_item_menu_item_description_label.visible = true
		
		var slots = not_equipped_slot_container.get_children()
		for i in slots.size():
			var slot = slots[i]
			var previous_slot_index = posmod(i - 1, slots.size())
			var next_slot_index = posmod(i + 1, slots.size())
			
			var previous_slot = slots[previous_slot_index]
			var next_slot = slots[next_slot_index]
			
			slot.focus_neighbour_left = previous_slot.get_path()
			slot.focus_neighbour_right = next_slot.get_path()
			slot.focus_neighbour_bottom = select_item_menu_done_button.get_path()
			
			slot.connect("mouse_entered", self, "_on_Slot_mouse_entered", [slot])
			slot.connect("gui_input", self, "_on_UnequippedSlot_gui_input", [slot, slot_to_change, slot_to_change.get_index()])
			#slot.connect("mouse_exited", self, "_on_Slot_mouse_exited", [slot])
			slot.connect("selected", self, "_on_UnequippedSlot_selected", [slot])
			#slot.connect("unselected", self, "_on_UnequippedSlot_unselected", [slot])
		
		if !slots.empty():
			slots[0].grab_focus()
			select_item_menu_done_button.focus_neighbour_top = slots[0].get_path()
		else:
			select_item_menu_done_button.grab_focus()
		
		select_item_menu_done_button.connect("pressed", self, "_on_SelectMenuDoneButton_pressed", [slot_to_change])


func _on_Slot_mouse_entered(slot) -> void:
	slot.grab_focus()


func _on_UnequippedSlot_gui_input(event, slot, old_slot, index) -> void:
	if event.is_action_pressed("ui_accept"):
		Globals.equipped_items[index] = slot.equipment
		Globals.available_items.erase(slot.equipment)
		if old_slot.equipment:
			Globals.available_items.append(old_slot.equipment)
		
		if Globals.player:
			slot.equipment.equip(Globals.player)
			if old_slot.equipment:
				old_slot.equipment.unequip(Globals.player)
		
		old_slot.equipment = slot.equipment
		
		Globals.save_data()
		
		_on_SelectMenuDoneButton_pressed(old_slot)

#func _on_Slot_mouse_exited(slot) -> void:
#	slot.release_focus()


func _on_Slot_selected(slot) -> void:
	#print(slot)
	#selected_equipment_slot = slot
	item_name_label.text = slot.equipment.name if slot.equipment else ""
	item_description_label.text = slot.equipment.description if slot.equipment else ""
	
	if slot.equipment:
		if slot.equipment.slot == Equipment.SLOT.ATTACK:
			item_type_label.text = "Attack"
		elif slot.equipment.slot == Equipment.SLOT.SPECIAL:
			item_type_label.text = "Special"
		elif slot.equipment.slot == Equipment.SLOT.PASSIVE:
			item_type_label.text = "Passive"
	



#func _on_Slot_unselected(slot) -> void:
#	#if slot == selected_equipment_slot:
#	#selected_equipment_slot = null
#	item_name_label.text = ""


func _on_UnequippedSlot_selected(slot) -> void:
	#item_to_equip = slot
	select_item_menu_item_label.text = slot.equipment.name if slot.equipment else ""
	select_item_menu_item_description_label.text = slot.equipment.description if slot.equipment else ""
	#select_item_menu_item_description_label.text = "Test"
	if slot.equipment:
		if slot.equipment.slot == Equipment.SLOT.ATTACK:
			select_item_menu_item_type_label.text = "Attack"
		elif slot.equipment.slot == Equipment.SLOT.SPECIAL:
			select_item_menu_item_type_label.text = "Special"
		elif slot.equipment.slot == Equipment.SLOT.PASSIVE:
			select_item_menu_item_type_label.text = "Passive"
	
	

#func _on_UnequippedSlot_unselected(slot) -> void:
#	#if slot == item_to_equip:
#	#	item_to_equip = null
#	select_item_menu_item_label.text = ""


func _on_DoneButton_pressed() -> void:
	#get_tree().paused = false
	visible = false
	#queue_free()
	var dialog = Dialogic.start("InventoryEnd")
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



func _on_SelectMenuDoneButton_pressed(slot_to_focus) -> void:
	for slot in not_equipped_slot_container.get_children():
		slot.queue_free()
	
	slot_to_focus.grab_focus()
	inventory.visible = true
	select_item_menu.visible = false
	select_item_menu_done_button.disconnect("pressed", self, "_on_SelectMenuDoneButton_pressed")
