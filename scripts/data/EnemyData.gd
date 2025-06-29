class_name EnemyData
extends Resource

@export var enemy_name: String
@export var level: int = 1
@export var base_stats: Stats
@export var abilities: Array[Ability] = []
@export var ai_behavior: AIBehavior

func _init():
	base_stats = Stats.new()
	ai_behavior = AIBehavior.new()
	ai_behavior.aggression_level = 0.8  # Enemies are more aggressive

func get_total_stats() -> Stats:
	var total = base_stats.duplicate()
	
	# Add level bonuses
	var level_bonus = (level - 1) * 2
	total.health += level_bonus
	total.mana += level_bonus / 2
	total.attack += level_bonus / 3
	total.defense += level_bonus / 3
	
	return total
