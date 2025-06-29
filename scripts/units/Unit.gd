class_name Unit
extends CharacterBody3D

signal health_changed(new_health: int, max_health: int)
signal mana_changed(new_mana: int, max_mana: int)
signal unit_died

@export var hero_data: HeroData
@export var is_player_controlled: bool = true

var current_health: int
var current_mana: int
var status_effects: Array[StatusEffect] = []
var ability_cooldowns: Dictionary = {}
var ai_behavior: AIBehavior

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_canvas: Control = $UICanvas
@onready var health_bar: ProgressBar = $UICanvas/HealthBar
@onready var mana_bar: ProgressBar = $UICanvas/ManaBar

func _ready():
	if hero_data:
		setup_from_hero_data(hero_data)

func setup_from_hero_data(data: HeroData):
	hero_data = data
	var stats = data.get_total_stats()
	current_health = stats.health
	current_mana = stats.mana
	ai_behavior = data.ai_behavior
	
	# Update UI
	update_health_bar()
	update_mana_bar()

func setup_from_enemy_data(data: EnemyData):
	# Similar setup but for enemy data
	var stats = data.get_total_stats()
	current_health = stats.health
	current_mana = stats.mana
	is_player_controlled = false
	
	update_health_bar()
	update_mana_bar()

func _physics_process(delta):
	# Handle movement and physics
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	move_and_slide()
	
	# Update status effects
	update_status_effects(delta)

func get_total_stats() -> Stats:
	var base_stats = hero_data.get_total_stats() if hero_data else Stats.new()
	
	# Apply synergy bonuses
	var synergy_bonuses = CombatManager.calculate_synergy_bonuses(self)
	for stat in synergy_bonuses:
		match stat:
			"attack":
				base_stats.attack += synergy_bonuses[stat]
			"defense":
				base_stats.defense += synergy_bonuses[stat]
			"speed":
				base_stats.speed += synergy_bonuses[stat]
	
	# Apply status effect modifiers
	for effect in status_effects:
		effect.apply_stat_modifiers(base_stats)
	
	return base_stats

func take_damage(damage: int, attacker: Unit = null):
	var total_stats = get_total_stats()
	var final_damage = max(1, damage - total_stats.defense)
	
	current_health = max(0, current_health - final_damage)
	health_changed.emit(current_health, total_stats.health)
	update_health_bar()
	
	# Play damage effect
	play_damage_effect()
	
	if current_health <= 0:
		die()

func heal(amount: int):
	var total_stats = get_total_stats()
	current_health = min(total_stats.health, current_health + amount)
	health_changed.emit(current_health, total_stats.health)
	update_health_bar()

func restore_mana(amount: int):
	var total_stats = get_total_stats()
	current_mana = min(total_stats.mana, current_mana + amount)
	mana_changed.emit(current_mana, total_stats.mana)
	update_mana_bar()

func die():
	unit_died.emit()
	CombatManager.handle_unit_death(self)
	# Play death animation
	if animation_player.has_animation("death"):
		animation_player.play("death")
	AudioManager.play_combat_sfx("death")

func is_alive() -> bool:
	return current_health > 0

func start_turn():
	# Reset movement, update cooldowns, etc.
	reduce_cooldowns()
	
	# AI decision making for non-player units
	if not is_player_controlled and ai_behavior:
		execute_ai_turn()

func end_turn():
	# End of turn processing
	pass

func execute_ai_turn():
	var action = ai_behavior.get_action_for_unit(self)
	match action:
		"attack":
			attack_nearest_enemy()
		"defend":
			enter_defensive_stance()
		"support":
			heal_weakest_ally()
		"move":
			move_to_optimal_position()

func attack_nearest_enemy() -> bool:
	var enemies = get_enemies_in_range(get_attack_range())
	if enemies.is_empty():
		return false
	
	var nearest_enemy = get_nearest_unit(enemies)
	if nearest_enemy:
		attack_unit(nearest_enemy)
		return true
	return false

func attack_unit(target: Unit):
	var stats = get_total_stats()
	var damage = stats.attack
	
	# Check accuracy
	if randf() * 100 > stats.accuracy:
		# Miss
		show_combat_text("MISS", Color.GRAY)
		return
	
	target.take_damage(damage, self)
	
	# Play attack animation
	if animation_player.has_animation("attack"):
		animation_player.play("attack")
	
	AudioManager.play_combat_sfx("sword_hit")

func get_enemies_in_range(range: float) -> Array[Unit]:
	var enemies: Array[Unit] = []
	var all_units = CombatManager.active_units
	
	for unit in all_units:
		if unit != self and unit.is_alive():
			# Check if enemy (different team)
			var is_enemy = (self in CombatManager.player_units) != (unit in CombatManager.player_units)
			if is_enemy and global_position.distance_to(unit.global_position) <= range:
				enemies.append(unit)
	
	return enemies

func get_allies_in_range(range: float) -> Array[Unit]:
	return CombatManager.get_allied_units_in_range(self, range)

func get_allies_needing_healing() -> Array[Unit]:
	var allies = get_allies_in_range(10.0)  # Check allies within 10 units
	var needing_healing: Array[Unit] = []
	
	for ally in allies:
		var ally_stats = ally.get_total_stats()
		if ally.current_health < ally_stats.health * 0.7:  # Below 70% health
			needing_healing.append(ally)
	
	return needing_healing

func get_nearest_unit(units: Array[Unit]) -> Unit:
	if units.is_empty():
		return null
	
	var nearest = units[0]
	var nearest_distance = global_position.distance_to(nearest.global_position)
	
	for unit in units:
		var distance = global_position.distance_to(unit.global_position)
		if distance < nearest_distance:
			nearest = unit
			nearest_distance = distance
	
	return nearest

func get_attack_range() -> float:
	# Base attack range, can be modified by weapons/abilities
	return 2.0

func get_initiative() -> int:
	return get_total_stats().speed + randi() % 10

func use_ability(ability: Ability, target: Unit = null, target_position: Vector3 = Vector3.ZERO) -> bool:
	return ability.use_ability(self, target, target_position)

func is_ability_on_cooldown(ability: Ability) -> bool:
	return ability_cooldowns.has(ability) and ability_cooldowns[ability] > 0

func set_ability_cooldown(ability: Ability, turns: int):
	ability_cooldowns[ability] = turns

func reduce_cooldowns():
	for ability in ability_cooldowns:
		ability_cooldowns[ability] = max(0, ability_cooldowns[ability] - 1)
		if ability_cooldowns[ability] <= 0:
			ability_cooldowns.erase(ability)

func add_status_effect(effect: StatusEffect):
	status_effects.append(effect)
	effect.apply_to_unit(self)

func update_status_effects(delta: float):
	for i in range(status_effects.size() - 1, -1, -1):
		var effect = status_effects[i]
		effect.update(delta)
		if effect.is_expired():
			effect.remove_from_unit(self)
			status_effects.remove_at(i)

func update_health_bar():
	if health_bar:
		var stats = get_total_stats()
		health_bar.max_value = stats.health
		health_bar.value = current_health

func update_mana_bar():
	if mana_bar:
		var stats = get_total_stats()
		mana_bar.max_value = stats.mana
		mana_bar.value = current_mana

func play_damage_effect():
	# Visual feedback for taking damage
	var tween = create_tween()
	tween.tween_property(mesh_instance, "modulate", Color.RED, 0.1)
	tween.tween_property(mesh_instance, "modulate", Color.WHITE, 0.1)

func show_combat_text(text: String, color: Color):
	# Create floating combat text
	var label = Label.new()
	label.text = text
	label.modulate = color
	ui_canvas.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position", label.position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

# AI helper methods
func retreat_to_safety() -> bool:
	# Find safe position away from enemies
	var safe_position = find_safe_position()
	if safe_position != Vector3.ZERO:
		move_to_position(safe_position)
		return true
	return false

func find_safe_position() -> Vector3:
	# Simple implementation - move away from nearest enemies
	var enemies = get_enemies_in_range(10.0)
	if enemies.is_empty():
		return Vector3.ZERO
	
	var flee_direction = Vector3.ZERO
	for enemy in enemies:
		flee_direction += (global_position - enemy.global_position).normalized()
	
	return global_position + flee_direction.normalized() * 5.0

func move_to_position(target_position: Vector3):
	# Simple movement towards position
	var direction = (target_position - global_position).normalized()
	velocity = direction * get_total_stats().speed

func move_to_optimal_position() -> bool:
	# Find optimal position based on role and formation preferences
	var optimal_pos = calculate_optimal_position()
	if optimal_pos != Vector3.ZERO:
		move_to_position(optimal_pos)
		return true
	return false

func calculate_optimal_position() -> Vector3:
	# Placeholder - implement based on class role and formation preferences
	return global_position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))

func heal_weakest_ally() -> bool:
	var allies = get_allies_needing_healing()
	if allies.is_empty():
		return false
	
	# Find weakest ally
	var weakest = allies[0]
	for ally in allies:
		if ally.current_health < weakest.current_health:
			weakest = ally
	
	# Use healing ability if available
	for ability in hero_data.abilities:
		if ability.ability_type == Ability.Type.HEAL and ability.can_use(self):
			return use_ability(ability, weakest)
	
	return false

func cast_best_ability() -> bool:
	# Find and cast the best available ability
	var best_ability = get_best_ability()
	if best_ability and best_ability.can_use(self):
		var target = find_best_target_for_ability(best_ability)
		return use_ability(best_ability, target)
	return false

func get_best_ability() -> Ability:
	# Simple implementation - return first usable ability
	for ability in hero_data.abilities:
		if ability.can_use(self):
			return ability
	return null

func find_best_target_for_ability(ability: Ability) -> Unit:
	match ability.target_type:
		Ability.TargetType.ENEMY:
			var enemies = get_enemies_in_range(ability.range)
			return get_nearest_unit(enemies)
		Ability.TargetType.ALLY:
			var allies = get_allies_needing_healing()
			return get_nearest_unit(allies)
		_:
			return null

func enter_defensive_stance():
	# Increase defense, reduce movement
	# This could be implemented as a status effect
	pass
