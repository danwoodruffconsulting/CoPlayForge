class_name Unit
extends CharacterBody3D

signal health_changed(new_health: int, max_health: int)
signal mana_changed(new_mana: int, max_mana: int)
signal unit_died
signal unit_clicked(unit: Unit)

@export var hero_data: HeroData
@export var is_player_controlled: bool = true

var current_health: int
var current_mana: int
var status_effects: Array[StatusEffect] = []
var ability_cooldowns: Dictionary = {}
var ai_behavior: AIBehavior

var mesh_instance: MeshInstance3D
var animation_player: AnimationPlayer
var ui_canvas: Control
var health_bar: ProgressBar
var mana_bar: ProgressBar
var click_area: Area3D

func _ready():
	create_unit_components()
	if hero_data:
		setup_from_hero_data(hero_data)

func create_unit_components():
	# Create mesh instance with a simple capsule (more character-like)
	mesh_instance = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.8
	mesh_instance.mesh = capsule_mesh
	add_child(mesh_instance)
	
	# Create a basic material (color will be set later when hero_data is available)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GRAY  # Default color until hero_data is set
	material.metallic = 0.2
	material.roughness = 0.8
	mesh_instance.material_override = material
	
	# Create a collision shape for physics
	var collision_shape = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.4
	shape.height = 1.8
	collision_shape.shape = shape
	add_child(collision_shape)
	
	# Create click detection area
	click_area = Area3D.new()
	var click_collision = CollisionShape3D.new()
	var click_shape = CapsuleShape3D.new()
	click_shape.radius = 0.5  # Slightly larger for easier clicking
	click_shape.height = 2.0
	click_collision.shape = click_shape
	click_area.add_child(click_collision)
	add_child(click_area)
	
	# Connect click detection
	click_area.input_event.connect(_on_click_area_input)
	
	# Create animation player for basic animations
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	create_basic_animations()
	
	# Create UI canvas for health/mana bars
	create_unit_ui()

func _on_click_area_input(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		unit_clicked.emit(self)

func get_unit_color() -> Color:
	if not hero_data:
		return Color.RED  # Enemy color
	
	# Different colors for different hero classes
	match hero_data.hero_class:
		HeroClass.Type.WARRIOR:
			return Color.STEEL_BLUE
		HeroClass.Type.MAGE:
			return Color.PURPLE
		HeroClass.Type.ARCHER:
			return Color.FOREST_GREEN
		HeroClass.Type.ROGUE:
			return Color.DARK_GRAY
		HeroClass.Type.HEALER:
			return Color.GOLD
		_:
			return Color.BLUE  # Default player color

func create_basic_animations():
	# Create idle animation
	var idle_animation = Animation.new()
	idle_animation.length = 2.0
	idle_animation.loop_mode = Animation.LOOP_LINEAR
	
	# Add position track for gentle bobbing
	var position_track = idle_animation.add_track(Animation.TYPE_POSITION_3D)
	idle_animation.track_set_path(position_track, NodePath("MeshInstance3D"))
	idle_animation.track_insert_key(position_track, 0.0, Vector3.ZERO)
	idle_animation.track_insert_key(position_track, 1.0, Vector3(0, 0.1, 0))
	idle_animation.track_insert_key(position_track, 2.0, Vector3.ZERO)
	
	# Add scale track for slight breathing effect
	var scale_track = idle_animation.add_track(Animation.TYPE_SCALE_3D)
	idle_animation.track_set_path(scale_track, NodePath("MeshInstance3D"))
	idle_animation.track_insert_key(scale_track, 0.0, Vector3(1, 1, 1))
	idle_animation.track_insert_key(scale_track, 1.0, Vector3(1, 1.05, 1))
	idle_animation.track_insert_key(scale_track, 2.0, Vector3(1, 1, 1))
	
	# Add attack animation
	var attack_animation = Animation.new()
	attack_animation.length = 0.8
	
	var attack_scale_track = attack_animation.add_track(Animation.TYPE_SCALE_3D)
	attack_animation.track_set_path(attack_scale_track, NodePath("MeshInstance3D"))
	attack_animation.track_insert_key(attack_scale_track, 0.0, Vector3(1, 1, 1))
	attack_animation.track_insert_key(attack_scale_track, 0.2, Vector3(1.2, 0.8, 1.2))  # Wind up
	attack_animation.track_insert_key(attack_scale_track, 0.4, Vector3(0.8, 1.3, 0.8))  # Strike
	attack_animation.track_insert_key(attack_scale_track, 0.8, Vector3(1, 1, 1))  # Return
	
	# Store animations in AnimationPlayer
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("idle", idle_animation)
	animation_library.add_animation("attack", attack_animation)
	animation_player.add_animation_library("default", animation_library)
	
	# Start with idle animation
	animation_player.play("default/idle")

func create_unit_ui():
	# Create a 3D UI using a SubViewport that follows the unit
	ui_canvas = Control.new()
	ui_canvas.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	ui_canvas.position = Vector2(0, -50)
	
	# For now, we'll add this to the main scene tree rather than as a child
	# This will be handled by the main scene to position UI elements correctly
	
	# Create health bar
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(80, 8)
	health_bar.position = Vector2(-40, -30)
	health_bar.value = 100
	health_bar.add_theme_color_override("background", Color.BLACK)
	health_bar.add_theme_color_override("fill", Color.GREEN)
	ui_canvas.add_child(health_bar)
	
	# Create mana bar
	mana_bar = ProgressBar.new()
	mana_bar.size = Vector2(80, 6)
	mana_bar.position = Vector2(-40, -20)
	mana_bar.value = 100
	mana_bar.add_theme_color_override("background", Color.BLACK)
	mana_bar.add_theme_color_override("fill", Color.BLUE)
	ui_canvas.add_child(mana_bar)

func setup_from_hero_data(data: HeroData):
	hero_data = data
	var stats = data.get_total_stats()
	current_health = stats.health
	current_mana = stats.mana
	ai_behavior = data.ai_behavior
	
	# Update unit color based on hero class
	update_unit_color()
	
	# Update UI
	update_health_bar()
	update_mana_bar()

func setup_from_enemy_data(data: EnemyData):
	# Similar setup but for enemy data
	var stats = data.get_total_stats()
	current_health = stats.health
	current_mana = stats.mana
	is_player_controlled = false
	
	# Update unit color (enemies are red)
	update_unit_color()
	
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

func take_damage(damage: int, source: Unit = null):
	var total_stats = get_total_stats()
	var actual_damage = max(1, damage - total_stats.defense)
	current_health = max(0, current_health - actual_damage)
	
	# Play hurt animation (scale briefly)
	var tween = create_tween()
	tween.tween_property(mesh_instance, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property(mesh_instance, "scale", Vector3(1, 1, 1), 0.1)
	
	# Update health bar
	update_health_bar()
	
	# Emit health changed signal
	health_changed.emit(current_health, total_stats.health)
	
	# Check if unit died
	if current_health <= 0:
		die()
	
	# Play damage audio
	AudioManager.play_combat_sfx("hit")

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
	# Play death animation (fade out)
	var tween = create_tween()
	tween.parallel().tween_property(mesh_instance, "modulate", Color.TRANSPARENT, 1.0)
	tween.parallel().tween_property(mesh_instance, "scale", Vector3(0.1, 0.1, 0.1), 1.0)
	
	unit_died.emit()
	
	# Remove after animation
	await tween.finished
	queue_free()

func play_animation(anim_name: String):
	if animation_player and animation_player.has_animation("default/" + anim_name):
		animation_player.play("default/" + anim_name)
		
		# Return to idle after attack animation
		if anim_name == "attack":
			await animation_player.animation_finished
			animation_player.play("default/idle")

func attack_target(target: Unit) -> bool:
	if not can_attack():
		return false
	
	# Play attack animation
	play_animation("attack")
	
	# Face the target
	look_at(target.global_position, Vector3.UP)
	
	# Calculate damage
	var my_stats = get_total_stats()
	var base_damage = my_stats.attack
	
	# Apply critical hit chance
	var is_critical = randf() * 100 < my_stats.critical_chance
	if is_critical:
		base_damage = int(base_damage * my_stats.critical_damage / 100.0)
	
	# Apply damage after a short delay (for animation timing)
	await get_tree().create_timer(0.4).timeout
	target.take_damage(base_damage, self)
	
	return true

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

func is_alive() -> bool:
	return current_health > 0

func can_attack() -> bool:
	# Check if unit can attack (not stunned, has mana for abilities, etc.)
	return current_health > 0 and not has_status_effect("stunned")

func has_status_effect(effect_name: String) -> bool:
	for effect in status_effects:
		if effect.effect_name == effect_name:
			return true
	return false

func update_unit_color():
	# Update the unit's material color based on hero class or enemy status
	if mesh_instance and mesh_instance.material_override:
		var material = mesh_instance.material_override as StandardMaterial3D
		if material:
			material.albedo_color = get_unit_color()
