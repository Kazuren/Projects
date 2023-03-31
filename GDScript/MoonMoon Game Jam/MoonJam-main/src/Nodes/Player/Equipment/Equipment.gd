class_name Equipment
extends Object


enum SLOT {
	ATTACK,
	SPECIAL,
	PASSIVE
}

var name: String
var id: int
var slot = SLOT.ATTACK
var gold = 0
var description = "Medium damage long range attack"
var texture: Texture = null


func _ready() -> void:
	pass # Replace with function body.


func equip(player) -> void:
	# connect to dash state for example
	pass


func unequip(player) -> void:
	pass


func use(player) -> void:
	pass


func enter(player, data: Dictionary = {}) -> void:
	pass


func physics_update(player, delta: float) -> void:
	pass


func exit(player) -> void:
	pass
