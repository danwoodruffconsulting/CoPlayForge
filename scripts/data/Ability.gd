class_name Ability
extends Resource

@export var ability_name: String
@export var description: String
@export var ability_type: Type
@export var target_type: TargetType
@export var mana_cost: int = 0
@export var cooldown: int = 0
@export var damage: int = 0
@export var healing: int = 0
@export var range: float = 1.0
@export var area_of_effect: float = 0.0
@export var effects: Array[StatusEffect] = []
@export var required_level: int = 1
@export var animation_name: String

enum Type {
	ATTACK,
	HEAL,
	BUFF,
	DEBUFF,
	SUMMON,
	TELEPORT,
	AREA_ATTACK,
	PASSIVE
}

enum TargetType {
	SELF,
	ALLY,
	ENEMY,
	ALL_ALLIES,
	ALL_ENEMIES,
	ALL_UNITS,
	GROUND,
	NONE
}

func _init():
	pass

func can_use(caster: Unit, target_position: Vector3 = Vector3.ZERO) -> bool:
	# Check mana cost
	if caster.current_mana < mana_cost:
		return false
	
	# Check cooldown
	if caster.is_ability_on_cooldown(self):
		return false
	
	# Check range if target is required
	if target_type != TargetType.SELF and target_type != TargetType.NONE:
		if target_position != Vector3.ZERO:
			var distance = caster.global_position.distance_to(target_position)
			if distance > range:
				return false
	
	return true

func use_ability(caster: Unit, target: Unit = null, target_position: Vector3 = Vector3.ZERO):
	if not can_use(caster, target_position):
		return false
	
	# Consume mana
	caster.current_mana -= mana_cost
	
	# Set cooldown
	caster.set_ability_cooldown(self, cooldown)
	
	# Apply effects based on ability type
	match ability_type:
		Type.ATTACK:
			if target:
				apply_damage(caster, target)
		Type.HEAL:
			if target:
				apply_healing(caster, target)
		Type.BUFF:
			apply_buff_effects(caster, target)
		Type.DEBUFF:
			apply_debuff_effects(caster, target)
		Type.AREA_ATTACK:
			apply_area_damage(caster, target_position)
		Type.SUMMON:
			summon_creature(caster, target_position)
	
	# Play animation and effects
	play_ability_effects(caster, target_position)
	
	return true

func apply_damage(caster: Unit, target: Unit):
	var final_damage = calculate_damage(caster, target)
	target.take_damage(final_damage, caster)
	
	# Apply status effects
	for effect in effects:
		target.add_status_effect(effect)

func apply_healing(caster: Unit, target: Unit):
	var final_healing = calculate_healing(caster)
	target.heal(final_healing)

func calculate_damage(caster: Unit, target: Unit) -> int:
	var base_damage = damage + caster.get_total_stats().attack
	var defense = target.get_total_stats().defense
	
	# Simple damage calculation with defense reduction
	var final_damage = max(1, base_damage - defense)
	
	# Check for critical hit
	if randf() * 100 < caster.get_total_stats().critical_chance:
		final_damage = int(final_damage * (caster.get_total_stats().critical_damage / 100.0))
	
	return final_damage

func calculate_healing(caster: Unit) -> int:
	# Healing scales with caster's mana or a healing power stat
	return healing + (caster.get_total_stats().mana / 5)

func apply_area_damage(caster: Unit, center_position: Vector3):
	var units_in_area = CombatManager.get_units_in_range(center_position, area_of_effect)
	for unit in units_in_area:
		if should_affect_unit(caster, unit):
			apply_damage(caster, unit)

func should_affect_unit(caster: Unit, target: Unit) -> bool:
	match target_type:
		TargetType.ALLY:
			return target in CombatManager.get_allied_units_in_range(caster, 999.0)
		TargetType.ENEMY:
			return target not in CombatManager.get_allied_units_in_range(caster, 999.0)
		TargetType.ALL_UNITS:
			return true
		_:
			return false

func apply_buff_effects(caster: Unit, target: Unit):
	if not target:
		target = caster
	
	for effect in effects:
		target.add_status_effect(effect)

func apply_debuff_effects(caster: Unit, target: Unit):
	if target:
		for effect in effects:
			target.add_status_effect(effect)

func summon_creature(caster: Unit, position: Vector3):
	# Implementation for summoning creatures
	pass

func play_ability_effects(caster: Unit, target_position: Vector3):
	# Play animation
	if animation_name and caster.has_method("play_animation"):
		caster.play_animation(animation_name)
	
	# Play sound effect
	AudioManager.play_combat_sfx(get_sfx_name())

func get_sfx_name() -> String:
	match ability_type:
		Type.ATTACK, Type.AREA_ATTACK:
			return "sword_hit"
		Type.HEAL:
			return "heal"
		_:
			return "magic_cast"
