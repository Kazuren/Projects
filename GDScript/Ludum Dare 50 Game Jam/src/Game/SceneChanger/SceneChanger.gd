extends Area2D


export(PackedScene) var scene_to_load


func _ready() -> void:
	connect("body_entered", self, "_on_Body_entered")


func _on_Body_entered(body: Node) -> void:
	if body is Player:
		change_scene()


func change_scene() -> void:
	ScreenFader.fade_in()
	get_tree().paused = true
	yield(ScreenFader, "animation_finished")
	ScreenFader.fade_out()
	get_tree().paused = false
	get_tree().change_scene(scene_to_load.resource_path)
