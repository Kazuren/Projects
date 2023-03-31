extends Node

signal player_set

const PATH = "user://data.save"

var data = {
	"progress": 0,
	"equipped_items": [],
	"available_items": [],
	"shop_items": [],
	"coins_collected": [],
	"coins": 0,
	"level_stats": {}
}

onready var RNG = RandomNumberGenerator.new()


# Keeps track if we're coming on a level from retry or if it's new
var from_retry: bool = false
var space_level: bool = false setget set_space_level


func set_space_level(value: bool) -> void:
	space_level = value
	if space_level:
		ScreenShaders.crt_material.set_shader_param("distort_intensity", 0.002)
		ScreenShaders.crt_material.set_shader_param("roll", true)
	else:
		ScreenShaders.crt_material.set_shader_param("distort_intensity", 0.00)
		ScreenShaders.crt_material.set_shader_param("roll", false)


var player = null setget set_player
var equipped_items: Array = [null, null, null, null]
var available_items: Array = []
var shop_items: Array = []
var progress: int = 0

var coins_collected = []
var coins: int = 0


var items = [
	"res://src/Nodes/Player/Equipment/Weapons/CumShooter.gd",
	"res://src/Nodes/Player/Equipment/Weapons/CumBlaster.gd",
	"res://src/Nodes/Player/Equipment/Weapons/SeekingCum.gd",
	"res://src/Nodes/Player/Equipment/Weapons/CumBomb.gd",
	"res://src/Nodes/Player/Equipment/Passives/DeadlyFart.gd",
	"res://src/Nodes/Player/Equipment/Passives/SilentFart.gd",
	"res://src/Nodes/Player/Equipment/Specials/Cum360.gd",
	"res://src/Nodes/Player/Equipment/Specials/CumBeam.gd"
]

var starting_equipped_items = [
	["res://src/Nodes/Player/Equipment/Weapons/CumShooter.gd", 0],
	["res://src/Nodes/Player/Equipment/Weapons/CumBlaster.gd", 1],
	["res://src/Nodes/Player/Equipment/Specials/Cum360.gd", 6]
]
var starting_available_items = [
	#["res://src/Nodes/Player/Equipment/Weapons/CumShooter.gd", 0]
]
var starting_shop_items = [
	["res://src/Nodes/Player/Equipment/Weapons/SeekingCum.gd", 2],
	["res://src/Nodes/Player/Equipment/Weapons/CumBomb.gd", 3],
	["res://src/Nodes/Player/Equipment/Passives/DeadlyFart.gd", 4],
	["res://src/Nodes/Player/Equipment/Passives/SilentFart.gd", 5],
	["res://src/Nodes/Player/Equipment/Specials/CumBeam.gd", 7]
]

var level_stats: Dictionary = {}


func level_completed(level_id: int, time: float, hp: int, max_hp: int, coins: int, max_coins: int, score: int) -> void:
	if level_stats.has(level_id):
		if level_stats[level_id].score < score:
			level_stats[level_id].time = time
			level_stats[level_id].hp = hp
			level_stats[level_id].max_hp = max_hp
			level_stats[level_id].coins = coins
			level_stats[level_id].max_coins = max_coins
			level_stats[level_id].score = score
	else:
		level_stats[level_id] = {
			"time": time,
			"hp": hp,
			"max_hp": max_hp,
			"coins": coins,
			"max_coins": max_coins,
			"score": score,
		}


func collect_coin(level_id, coin_id) -> void:
	coins_collected.append({
		"level": level_id,
		"coin": coin_id,
	})


func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	RNG.randomize()
	load_data()
	#Events.connect("item_unequipped", self, "save_data")
	#Events.connect("item_equipped", self, "save_data")
	#Events.connect("item_bought", self, "save_data")
	#Events.connect("progress_changed", self, "save_data")
	pass # Replace with function body.
	#print(data.equipped_items)


func save_data():
	data.equipped_items = []
	data.available_items = []
	data.shop_items = []
	data.coins_collected = []
	data.progress = progress
	data.coins = coins
	
	data.level_stats = {}
	
	
	for item in equipped_items:
		if item:
			data.equipped_items.append(item.id)
		else:
			data.equipped_items.append(null)
	for item in available_items:
		data.available_items.append(item.id)
	for item in shop_items:
		data.shop_items.append(item.id)
	
	
	for coin in coins_collected:
		data.coins_collected.append({
			"level": coin.level,
			"coin": coin.coin
		})
	
	
	for level_id in level_stats.keys():
		var level = level_stats[level_id]
		data.level_stats[level_id] = {
			"time": level.time,
			"hp": level.hp,
			"max_hp": level.max_hp,
			"coins": level.coins,
			"max_coins": level.max_coins,
			"score": level.score,
		}
		
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	#print(JSON.print(data))
	file.store_line(JSON.print(data))
	file.close()
 


func load_data():
	var file = File.new()
	if not file.file_exists(PATH):
		data = {
			"progress": 0,
			"equipped_items": [],
			"available_items": [],
			"shop_items": [],
			"coins_collected": [],
			"coins": 0,
			"level_stats": {}
		}
		save_data()
	
	file.open(PATH, File.READ)
	data = JSON.parse(file.get_line()).result
	file.close()
	
	data.progress = data.progress if data.has("progress") else 0
	data.coins = data.coins if data.has("coins") else 0
	data.coins_collected = data.coins_collected if data.has("coins_collected") else []
	
	progress = data.progress
	coins = data.coins
	
	
	# Convert floats to ints because JSON makes them floats
	for i in data.equipped_items.size():
		var id = data.equipped_items[i]
		if typeof(id) == TYPE_REAL:
			data.equipped_items[i] = int(id)
	
	for i in data.available_items.size():
		var id = data.available_items[i]
		if typeof(id) == TYPE_REAL:
			data.available_items[i] = int(id)
	
	for i in data.shop_items.size():
		var id = data.shop_items[i]
		if typeof(id) == TYPE_REAL:
			data.shop_items[i] = int(id)
	
	for i in data.coins_collected.size():
		var coin = data.coins_collected[i]
		var level_id = coin.level
		var coin_id = coin.coin
		if typeof(level_id) == TYPE_REAL:
			coin.level = int(level_id)
		if typeof(coin_id) == TYPE_REAL:
			coin.coin = int(coin_id)
	
	coins_collected = data.coins_collected
	
	for key in data.level_stats.keys():
		data.level_stats[int(key)] = data.level_stats[key]
		data.level_stats.erase(key)
		
	level_stats = data.level_stats
	
	
	for i in starting_equipped_items.size():
		var _item = starting_equipped_items[i]
		var item = _item[0]
		var id = _item[1]
		
		if id in data.available_items:
			var Item = load(items[id])
			available_items.append(Item.new())
		elif id in data.shop_items:
			var Item = load(items[id])
			shop_items.append(Item.new())
		elif id in data.equipped_items:
			var Item = load(items[id])
			var index = data.equipped_items.find(id)
			equipped_items[index] = Item.new()
		else:
			var Item = load(items[id])
			equipped_items[i] = Item.new()
	
	
	for i in starting_available_items.size():
		var _item = starting_available_items[i]
		var item = _item[0]
		var id = _item[1]
		
		if id in data.equipped_items:
			var Item = load(items[id])
			var index = data.equipped_items.find(id)
			equipped_items[index] = Item.new()
		elif id in data.shop_items:
			var Item = load(items[id])
			shop_items.append(Item.new())
		else:
			var Item = load(items[id])
			available_items.append(Item.new())
	
	
	for i in starting_shop_items.size():
		var _item = starting_shop_items[i]
		var item = _item[0]
		var id = _item[1]
		
		if id in data.available_items:
			var Item = load(items[id])
			available_items.append(Item.new())
		elif id in data.equipped_items:
			var Item = load(items[id])
			var index = data.equipped_items.find(id)
			equipped_items[index] = Item.new()
		else:
			var Item = load(items[id])
			shop_items.append(Item.new())
	
	save_data()



#	for i in data.equipped_items.size():
#		var id = data.equipped_items[i]
#		if id:
#			var Item = load(items[id])
#			equipped_items.append(Item.new())
#		else:
#			pass
#
#	for id in data.available_items:
#		var Item = load(items[id])
#		available_items.append(Item.new())
#
#	for id in data.shop_items:
#		var Item = load(items[id])
#		shop_items.append(Item.new())
	

func set_player(value) -> void:
	player = value
	emit_signal("player_set", player)
