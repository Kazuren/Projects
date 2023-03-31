extends Control


onready var confirm_button = $CenterContainer/VBoxContainer/ConfirmButton
onready var line_edit = $CenterContainer/VBoxContainer/LineEdit


func _ready() -> void:
	ScreenFader.fade_out("1.0")
	yield(ScreenFader, "animation_finished")
	confirm_button.connect("pressed", self, "_on_ConfirmButton_pressed")


func _on_ConfirmButton_pressed() -> void:
	var player_name = line_edit.text.strip_edges()
	if player_name == "":
		return
	Dialogic.set_variable("PlayerName", player_name)
	#TODO change npc names if player chooses one of them
	Dialogic.set_variable("Player", "[color=#cf573c]" + player_name + "[/color]")
	if player_name.to_lower() == "sarah":
		Dialogic.set_variable("WifeName", "Karen")
		Dialogic.set_variable("Wife", "[color=#df84a5]Karen[/color]")
	if player_name.to_lower() == "carl":
		Dialogic.set_variable("ScientistName", "Albert")
		Dialogic.set_variable("Scientist", "[color=#a8ca58]Albert[/color]")
	if player_name.to_lower() == "nina":
		Dialogic.set_variable("DaughterName", "Emily")
		Dialogic.set_variable("Daughter", "[color=#73bed3]Emily[/color]")
	if player_name.to_lower() == "tanner":
		Dialogic.set_variable("FriendName", "Chad")
		Dialogic.set_variable("Friend", "[color=#3c5e8b]Chad[/color]")
	
	
	ScreenFader.fade_in("1.0")
	yield(ScreenFader, "animation_finished")
	Audio.stop_music()
	Globals.game_started = true
	get_tree().change_scene("res://src/Scenes/Lab1/Lab1.tscn")

