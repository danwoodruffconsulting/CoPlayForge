class_name PlayerData
extends Resource

@export var player_name: String = "Player"
@export var unlocked_heroes: Array[HeroData] = []
@export var current_level: int = 1
@export var total_experience: int = 0
@export var gold: int = 100

func _init():
	# Start with some basic heroes unlocked
	unlock_starter_heroes()

func unlock_starter_heroes():
	# Create starter heroes
	var warrior = HeroData.new()
	warrior.hero_name = "Starter Warrior"
	warrior.hero_class = HeroClass.Type.WARRIOR
	warrior.level = 1
	
	var archer = HeroData.new()
	archer.hero_name = "Starter Archer"
	archer.hero_class = HeroClass.Type.ARCHER
	archer.level = 1
	
	var mage = HeroData.new()
	mage.hero_name = "Starter Mage"
	mage.hero_class = HeroClass.Type.MAGE
	mage.level = 1
	
	unlocked_heroes = [warrior, archer, mage]

func unlock_hero(hero: HeroData):
	if hero not in unlocked_heroes:
		unlocked_heroes.append(hero)

func get_party_limit() -> int:
	# Party size increases with player level
	return min(8, 3 + (current_level / 5))
