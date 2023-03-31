extends Control


var player

var full_heart_texture = preload("res://src/Interface/GameInterface/heart.tres")
var empty_heart_texture = null#preload("res://src/Interface/GameInterface/heart.tres")
var full_cum_stacks_texture = preload("res://src/Interface/GameInterface/cumstack.tres")

var grayscale_shader = preload("res://Assets/Shaders/grayscale.shader")

onready var heart_bar = $MarginContainer/VBoxContainer/HeartBar
onready var cum_stacks_bar = $MarginContainer/VBoxContainer/CumStacksBar
onready var coin_amount = $CoinContainer/HBoxContainer/HBoxContainer/CoinAmount

func _ready() -> void:
	Globals.connect("player_set", self, "_on_player_set")


func _on_player_set(player: Player) -> void:
	self.player = player
	for child in heart_bar.get_children():
		child.free()
	
	for child in cum_stacks_bar.get_children():
		child.free()
	
	player.connect("max_health_changed", self, "_on_Player_max_health_changed")
	player.connect("health_changed", self, "_on_Player_health_changed")
	player.connect("cum_stacks_changed", self, "_on_Player_cum_stacks_changed")
	player.connect("max_cum_stacks_changed", self, "_on_Player_max_cum_stacks_changed")
	
	
	_on_Player_max_health_changed(player.max_health)
	_on_Player_health_changed(player.health)
	_on_Player_max_cum_stacks_changed(player.max_cum_stacks)
	_on_Player_cum_stacks_changed(player.cum_stacks)


func _process(delta: float) -> void:
	coin_amount.text = str(Globals.coins)


func _on_Player_max_health_changed(max_health: int) -> void:
	var hearts = heart_bar.get_children()
	if max_health > hearts.size():
		for i in max_health - hearts.size():
			var texture_rect = TextureRect.new()
			heart_bar.add_child(texture_rect)
			texture_rect.texture = full_heart_texture
			texture_rect.material = ShaderMaterial.new()
			texture_rect.material.shader = grayscale_shader
	else:
		for i in hearts.size():
			var heart = hearts[i]
			if i > max_health:
				heart.queue_free()


func _on_Player_health_changed(health: int) -> void:
	var hearts = heart_bar.get_children()
	for i in hearts.size():
		var heart = hearts[i]
		if i < health:
			heart.texture = full_heart_texture
			heart.material.shader = null
		else:
			heart.material.shader = grayscale_shader
			#heart.texture = empty_texture


func _on_Player_max_cum_stacks_changed(max_cum_stacks: int) -> void:
	var cum_stacks = cum_stacks_bar.get_children()
	if max_cum_stacks > cum_stacks.size():
		for i in max_cum_stacks - cum_stacks.size():
			var texture_rect = TextureRect.new()
			cum_stacks_bar.add_child(texture_rect)
			texture_rect.texture = full_cum_stacks_texture
			texture_rect.rect_min_size = Vector2(64, 64)
			texture_rect.expand = true
			texture_rect.material = ShaderMaterial.new()
			texture_rect.material.shader = grayscale_shader
	else:
		for i in cum_stacks.size():
			var cum_stack = cum_stacks[i]
			if i > max_cum_stacks:
				cum_stack.queue_free()


func _on_Player_cum_stacks_changed(cum_stacks: int) -> void:
	var cum_stacks_children = cum_stacks_bar.get_children()
	for i in cum_stacks_children.size():
		var cum_stack = cum_stacks_children[i]
		if i < cum_stacks:
			cum_stack.texture = full_cum_stacks_texture
			cum_stack.material.shader = null
		else:
			cum_stack.material.shader = grayscale_shader
