extends Sprite

signal level_finished


onready var player_detector = $PlayerDetector


func _ready() -> void:
	player_detector.connect("body_entered", self, "_on_PlayerDetector_body_entered")



func _on_PlayerDetector_body_entered(body: Node) -> void:
	if body is Player:
		player_detector.set_deferred("monitoring", false)
		player_detector.set_deferred("monitorable", false)
		emit_signal("level_finished")
