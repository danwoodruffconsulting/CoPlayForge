class_name HeroData
extends Resource

@export var hero_name: String
@export var hero_class: HeroClass.Type
@export var level: int = 1
@export var experience: int = 0
@export var base_stats: Stats
@export var equipment: Equipment
@export var abilities: Array[Ability] = []
@export var ai_behavior: AIBehavior

# Low stat design - these are the base values at level 1
@export var base_health: int = 20
@export var base_mana: int = 10
@export var base_attack: int = 5
@export var base_defense: int = 3
@export var base_speed: int = 4
@export var base_accuracy: int = 75

func _init():
	base_stats = Stats.new()
	equipment = Equipment.new()
	ai_behavior = AIBehavior.new()

func get_total_stats() -> Stats:
	var total = base_stats.duplicate()
	
	# Add equipment bonuses
	if equipment:
		total.add_stats(equipment.get_total_stats())
	
	# Add level bonuses (minimal growth)
	var level_bonus = (level - 1) * 2  # Very slow growth
	total.health += level_bonus
	total.mana += level_bonus / 2
	total.attack += level_bonus / 3
	total.defense += level_bonus / 3
	
	return total

func can_level_up() -> bool:
	return experience >= get_experience_required()

func get_experience_required() -> int:
	return level * 100  # Simple linear progression

func level_up():
	if can_level_up():
		level += 1
		experience -= get_experience_required()
		# Unlock new abilities at certain levels
		unlock_abilities_for_level()

func unlock_abilities_for_level():
	var class_abilities = HeroClassManager.get_abilities_for_class(hero_class)
	for ability in class_abilities:
		if ability.required_level <= level and ability not in abilities:
			abilities.append(ability)

func get_synergy_classes() -> Array[HeroClass.Type]:
	return HeroClassManager.get_synergy_classes(hero_class)
