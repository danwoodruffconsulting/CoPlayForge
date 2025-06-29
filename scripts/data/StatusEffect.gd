class_name StatusEffect
extends Resource

@export var effect_name: String
@export var description: String
@export var duration: float = 0.0  # In seconds, 0 = permanent until removed
@export var effect_type: Type
@export var stat_modifiers: Stats
@export var damage_per_tick: int = 0
@export var healing_per_tick: int = 0
@export var tick_interval: float = 1.0

var time_remaining: float
var last_tick_time: float

enum Type {
	BUFF,
	DEBUFF,
	DAMAGE_OVER_TIME,
	HEAL_OVER_TIME,
	STUN,
	SLOW,
	HASTE
}

func _init():
	stat_modifiers = Stats.new()
	time_remaining = duration

func apply_to_unit(unit: Unit):
	# Apply initial effects
	match effect_type:
		Type.STUN:
			# Prevent unit from acting
			pass
		Type.SLOW:
			# Reduce movement speed
			pass

func update(delta: float):
	if duration > 0:
		time_remaining -= delta
	
	# Handle damage/healing over time
	last_tick_time += delta
	if last_tick_time >= tick_interval:
		tick_effect()
		last_tick_time = 0.0

func tick_effect():
	# Apply periodic effects
	if damage_per_tick > 0:
		# Apply damage
		pass
	
	if healing_per_tick > 0:
		# Apply healing
		pass

func is_expired() -> bool:
	return duration > 0 and time_remaining <= 0

func remove_from_unit(unit: Unit):
	# Remove effects when status effect expires
	pass

func apply_stat_modifiers(stats: Stats):
	stats.add_stats(stat_modifiers)
