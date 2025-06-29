extends Node

signal combat_started
signal combat_ended
signal unit_died(unit: Unit)
signal turn_changed

var active_units: Array[Unit] = []
var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var current_turn_unit: Unit
var turn_queue: Array[Unit] = []

func _ready():
	pass

func start_combat(player_team: Array[HeroData], enemy_team: Array[EnemyData]):
	# Initialize combat
	active_units.clear()
	player_units.clear()
	enemy_units.clear()
	turn_queue.clear()
	
	# Create player units
	for hero_data in player_team:
		var unit = create_unit_from_hero_data(hero_data)
		player_units.append(unit)
		active_units.append(unit)
	
	# Create enemy units
	for enemy_data in enemy_team:
		var unit = create_unit_from_enemy_data(enemy_data)
		enemy_units.append(unit)
		active_units.append(unit)
	
	# Initialize turn order based on speed/initiative
	calculate_turn_order()
	combat_started.emit()
	process_next_turn()

func create_unit_from_hero_data(hero_data: HeroData) -> Unit:
	var unit = Unit.new()
	unit.setup_from_hero_data(hero_data)
	return unit

func create_unit_from_enemy_data(enemy_data: EnemyData) -> Unit:
	var unit = Unit.new()
	unit.setup_from_enemy_data(enemy_data)
	return unit

func calculate_turn_order():
	# Sort units by speed/initiative
	turn_queue = active_units.duplicate()
	turn_queue.sort_custom(func(a, b): return a.get_initiative() > b.get_initiative())

func process_next_turn():
	if turn_queue.is_empty():
		calculate_turn_order()
	
	if not turn_queue.is_empty():
		current_turn_unit = turn_queue.pop_front()
		if current_turn_unit and current_turn_unit.is_alive():
			turn_changed.emit()
			current_turn_unit.start_turn()
		else:
			process_next_turn()

func end_current_turn():
	if current_turn_unit:
		current_turn_unit.end_turn()
		current_turn_unit = null
	
	# Check win/lose conditions
	check_combat_end()
	
	if GameManager.game_state == GameManager.GameState.COMBAT:
		process_next_turn()

func check_combat_end():
	var alive_players = player_units.filter(func(unit): return unit.is_alive())
	var alive_enemies = enemy_units.filter(func(unit): return unit.is_alive())
	
	if alive_players.is_empty():
		GameManager.game_over()
		combat_ended.emit()
	elif alive_enemies.is_empty():
		GameManager.complete_level()
		combat_ended.emit()

func handle_unit_death(unit: Unit):
	active_units.erase(unit)
	turn_queue.erase(unit)
	unit_died.emit(unit)

func get_units_in_range(position: Vector3, range: float) -> Array[Unit]:
	var units_in_range: Array[Unit] = []
	for unit in active_units:
		if unit.global_position.distance_to(position) <= range:
			units_in_range.append(unit)
	return units_in_range

func calculate_synergy_bonuses(unit: Unit) -> Dictionary:
	var bonuses = {}
	var nearby_allies = get_allied_units_in_range(unit, 3.0)
	
	# Calculate class-specific synergy bonuses
	for ally in nearby_allies:
		var synergy = HeroClassManager.get_synergy_bonus(unit.hero_class, ally.hero_class)
		if synergy:
			for stat in synergy:
				bonuses[stat] = bonuses.get(stat, 0) + synergy[stat]
	
	return bonuses

func get_allied_units_in_range(unit: Unit, range: float) -> Array[Unit]:
	var allies: Array[Unit] = []
	var target_array = player_units if unit in player_units else enemy_units
	
	for ally in target_array:
		if ally != unit and ally.global_position.distance_to(unit.global_position) <= range:
			allies.append(ally)
	
	return allies
