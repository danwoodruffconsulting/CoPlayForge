class_name Stats
extends Resource

@export var health: int = 20
@export var mana: int = 10
@export var attack: int = 5
@export var defense: int = 3
@export var speed: int = 4
@export var accuracy: int = 75
@export var evasion: int = 10
@export var critical_chance: int = 5
@export var critical_damage: int = 150  # Percentage

func _init():
	pass

func duplicate() -> Stats:
	var new_stats = Stats.new()
	new_stats.health = health
	new_stats.mana = mana
	new_stats.attack = attack
	new_stats.defense = defense
	new_stats.speed = speed
	new_stats.accuracy = accuracy
	new_stats.evasion = evasion
	new_stats.critical_chance = critical_chance
	new_stats.critical_damage = critical_damage
	return new_stats

func add_stats(other: Stats):
	health += other.health
	mana += other.mana
	attack += other.attack
	defense += other.defense
	speed += other.speed
	accuracy += other.accuracy
	evasion += other.evasion
	critical_chance += other.critical_chance
	critical_damage += other.critical_damage

func multiply_by(multiplier: float):
	health = int(health * multiplier)
	mana = int(mana * multiplier)
	attack = int(attack * multiplier)
	defense = int(defense * multiplier)
	speed = int(speed * multiplier)
	accuracy = int(accuracy * multiplier)
	evasion = int(evasion * multiplier)
	critical_chance = int(critical_chance * multiplier)
	critical_damage = int(critical_damage * multiplier)
