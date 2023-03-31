extends KinematicBody2D

signal death

const DeathEffect = preload("res://src/Nodes/Environment/DeathEffect.tscn")

export(int) var health = 850 setget set_health
export(int) var max_health = 850

onready var yapping_position = $Pivot/YappingAttackPosition
onready var beam_position = $Pivot/BeamAttackPosition
onready var beam = $Pivot/BeamAttackPosition/Beam
onready var pivot = $Pivot
onready var hurtbox = $Pivot/Hurtbox
onready var effects_player = $EffectsPlayer
onready var death_effect_position = $DeathEffectPosition
onready var sprite = $Pivot/Sprite

var dead: bool = false


func _ready() -> void:
	add_to_group("enemies")
	effects_player.play("RESET")
	hurtbox.connect("area_entered", self, "_on_Hurtbox_area_entered")


func show_beam():
	beam.visible = true


func hide_beam():
	beam.visible = false


func set_health(value: int) -> void:
	health = value
	if health <= 0:
		emit_signal("death")
		# possibly make a particles death animation here
		var death_effect = DeathEffect.instance()
		# switch to sprite when we have it
		death_effect.initialize(sprite.texture)
		death_effect.speed_scale = 0.5
		get_tree().root.add_child(death_effect)
		death_effect.scale.x = pivot.scale.x
		death_effect.global_position = death_effect_position.global_position
		dead = true
		queue_free()


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		self.health -= area.damage
		effects_player.play("Hit")
