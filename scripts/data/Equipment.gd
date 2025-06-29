class_name Equipment
extends Resource

class EquipmentItem:
	var item_name: String
	var stat_bonuses: Stats
	var special_effects: Array[String] = []
	var description: String
	
	func _init():
		stat_bonuses = Stats.new()

# Don't export complex types that aren't resources
var weapon: EquipmentItem
var armor: EquipmentItem
var accessory: EquipmentItem

func _init():
	pass

func get_total_stats() -> Stats:
	var total = Stats.new()
	
	if weapon:
		total.add_stats(weapon.stat_bonuses)
	
	if armor:
		total.add_stats(armor.stat_bonuses)
	
	if accessory:
		total.add_stats(accessory.stat_bonuses)
	
	return total
