extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var player_units_container: Node3D = $Battlefield/PlayerUnits
@onready var enemy_units_container: Node3D = $Battlefield/EnemyUnits
@onready var ui: Control = $UI/MainUI
@onready var turn_display: Label = $UI/MainUI/HUD/TurnDisplay
@onready var unit_info_panel: Panel = $UI/MainUI/UnitInfo

var selected_unit: Unit
var camera_controller: CameraController

class_name Main

func _ready():
	# Initialize the game
	setup_camera_controller()
	setup_ui_connections()
	start_demo_battle()

func setup_camera_controller():
	camera_controller = CameraController.new()
	camera_controller.setup(camera)
	add_child(camera_controller)

func setup_ui_connections():
	# Connect UI buttons
	var attack_button = $UI/MainUI/HUD/ActionButtons/AttackButton
	var defend_button = $UI/MainUI/HUD/ActionButtons/DefendButton
	var ability_button = $UI/MainUI/HUD/ActionButtons/AbilityButton
	var end_turn_button = $UI/MainUI/HUD/ActionButtons/EndTurnButton
	
	attack_button.pressed.connect(_on_attack_button_pressed)
	defend_button.pressed.connect(_on_defend_button_pressed)
	ability_button.pressed.connect(_on_ability_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	# Connect combat manager signals
	CombatManager.combat_started.connect(_on_combat_started)
	CombatManager.combat_ended.connect(_on_combat_ended)
	CombatManager.turn_changed.connect(_on_turn_changed)

func start_demo_battle():
	# Create demo hero data
	var player_heroes: Array[HeroData] = []
	var enemy_data: Array[EnemyData] = []
	
	# Create a few test heroes
	for i in range(3):
		var hero = HeroData.new()
		hero.hero_name = "Hero " + str(i + 1)
		hero.hero_class = HeroClass.Type.values()[i % 5]  # Cycle through first 5 classes
		hero.level = 1
		player_heroes.append(hero)
	
	# Create test enemies
	for i in range(2):
		var enemy = EnemyData.new()
		enemy.enemy_name = "Enemy " + str(i + 1)
		enemy.level = 1
		enemy_data.append(enemy)
	
	# Start combat
	CombatManager.start_combat(player_heroes, enemy_data)

func _on_combat_started():
	print("Combat started!")
	spawn_units()

func spawn_units():
	# Spawn player units
	for i in range(CombatManager.player_units.size()):
		var unit = CombatManager.player_units[i]
		spawn_unit(unit, true, i)
	
	# Spawn enemy units
	for i in range(CombatManager.enemy_units.size()):
		var unit = CombatManager.enemy_units[i]
		spawn_unit(unit, false, i)

func spawn_unit(unit: Unit, is_player: bool, index: int):
	var container = player_units_container if is_player else enemy_units_container
	var position_offset = Vector3(index * 2, 0, 0 if is_player else 8)
	
	unit.global_position = position_offset
	container.add_child(unit)
	
	# Connect unit signals
	unit.unit_died.connect(_on_unit_died)
	
	# Make unit selectable for player units
	if is_player:
		unit.input_event.connect(_on_unit_clicked.bind(unit))

func _on_unit_clicked(unit: Unit, camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton and event.pressed:
		select_unit(unit)

func select_unit(unit: Unit):
	# Deselect previous unit
	if selected_unit:
		deselect_unit(selected_unit)
	
	selected_unit = unit
	highlight_unit(unit)
	update_unit_info_panel(unit)

func deselect_unit(unit: Unit):
	remove_unit_highlight(unit)

func highlight_unit(unit: Unit):
	# Add visual highlight to selected unit
	if unit.mesh_instance:
		unit.mesh_instance.material_override = preload("res://materials/highlight_material.tres")

func remove_unit_highlight(unit: Unit):
	if unit.mesh_instance:
		unit.mesh_instance.material_override = null

func update_unit_info_panel(unit: Unit):
	var unit_name_label = $UI/MainUI/UnitInfo/InfoContent/UnitName
	var class_name_label = $UI/MainUI/UnitInfo/InfoContent/ClassName
	var health_bar = $UI/MainUI/UnitInfo/InfoContent/StatsContainer/HealthBar
	var health_label = $UI/MainUI/UnitInfo/InfoContent/StatsContainer/HealthLabel
	var mana_bar = $UI/MainUI/UnitInfo/InfoContent/StatsContainer/ManaBar
	var mana_label = $UI/MainUI/UnitInfo/InfoContent/StatsContainer/ManaLabel
	
	unit_name_label.text = unit.hero_data.hero_name if unit.hero_data else "Enemy"
	class_name_label.text = HeroClass.get_class_name(unit.hero_data.hero_class) if unit.hero_data else "Enemy"
	
	var stats = unit.get_total_stats()
	health_bar.max_value = stats.health
	health_bar.value = unit.current_health
	health_label.text = "Health: %d/%d" % [unit.current_health, stats.health]
	
	mana_bar.max_value = stats.mana
	mana_bar.value = unit.current_mana
	mana_label.text = "Mana: %d/%d" % [unit.current_mana, stats.mana]

func _on_turn_changed():
	var current_unit = CombatManager.current_turn_unit
	if current_unit:
		turn_display.text = "Turn: " + (current_unit.hero_data.hero_name if current_unit.hero_data else "Enemy")
		
		# Auto-select if it's a player unit
		if current_unit in CombatManager.player_units:
			select_unit(current_unit)

func _on_combat_ended():
	print("Combat ended!")
	if CombatManager.player_units.filter(func(u): return u.is_alive()).is_empty():
		show_defeat_screen()
	else:
		show_victory_screen()

func show_victory_screen():
	# Show victory UI
	var victory_label = Label.new()
	victory_label.text = "VICTORY!"
	victory_label.add_theme_font_size_override("font_size", 48)
	victory_label.anchor_left = 0.5
	victory_label.anchor_right = 0.5
	victory_label.anchor_top = 0.5
	victory_label.anchor_bottom = 0.5
	victory_label.offset_left = -100
	victory_label.offset_right = 100
	victory_label.offset_top = -25
	victory_label.offset_bottom = 25
	ui.add_child(victory_label)

func show_defeat_screen():
	# Show defeat UI
	var defeat_label = Label.new()
	defeat_label.text = "DEFEAT!"
	defeat_label.add_theme_font_size_override("font_size", 48)
	defeat_label.anchor_left = 0.5
	defeat_label.anchor_right = 0.5
	defeat_label.anchor_top = 0.5
	defeat_label.anchor_bottom = 0.5
	defeat_label.offset_left = -100
	defeat_label.offset_right = 100
	defeat_label.offset_top = -25
	defeat_label.offset_bottom = 25
	ui.add_child(defeat_label)

func _on_unit_died(unit: Unit):
	print("Unit died: ", unit.hero_data.hero_name if unit.hero_data else "Enemy")

# UI Button handlers
func _on_attack_button_pressed():
	if selected_unit and selected_unit == CombatManager.current_turn_unit:
		selected_unit.attack_nearest_enemy()
		CombatManager.end_current_turn()

func _on_defend_button_pressed():
	if selected_unit and selected_unit == CombatManager.current_turn_unit:
		selected_unit.enter_defensive_stance()
		CombatManager.end_current_turn()

func _on_ability_button_pressed():
	if selected_unit and selected_unit == CombatManager.current_turn_unit:
		selected_unit.cast_best_ability()
		CombatManager.end_current_turn()

func _on_end_turn_button_pressed():
	if CombatManager.current_turn_unit:
		CombatManager.end_current_turn()

func _input(event):
	# Handle camera controls
	if camera_controller:
		camera_controller.handle_input(event)

class CameraController:
	var camera: Camera3D
	var is_rotating: bool = false
	var rotation_speed: float = 2.0
	var zoom_speed: float = 2.0
	var last_mouse_position: Vector2
	
	func setup(cam: Camera3D):
		camera = cam
	
	func handle_input(event: InputEvent):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				is_rotating = event.pressed
				last_mouse_position = event.position
		
		elif event is InputEventMouseMotion and is_rotating:
			var delta = event.position - last_mouse_position
			
			# Rotate camera around target
			var target = Vector3.ZERO  # Center of battlefield
			var radius = camera.global_position.distance_to(target)
			
			# Horizontal rotation
			var angle_h = delta.x * rotation_speed * 0.01
			camera.global_position = camera.global_position.rotated(Vector3.UP, -angle_h)
			
			# Vertical rotation (limited)
			var angle_v = delta.y * rotation_speed * 0.01
			var up_vector = camera.global_position.y
			if (up_vector > 2.0 and angle_v < 0) or (up_vector < 15.0 and angle_v > 0):
				var right_vector = camera.global_transform.basis.x
				camera.global_position = camera.global_position.rotated(right_vector, -angle_v)
			
			camera.look_at(target, Vector3.UP)
			last_mouse_position = event.position
		
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(-1.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(1.0)
	
	func zoom_camera(direction: float):
		var zoom_amount = direction * zoom_speed
		var target = Vector3.ZERO
		var to_target = (target - camera.global_position).normalized()
		camera.global_position += to_target * zoom_amount
		
		# Limit zoom distance
		var distance = camera.global_position.distance_to(target)
		if distance < 5.0:
			camera.global_position = target + (camera.global_position - target).normalized() * 5.0
		elif distance > 30.0:
			camera.global_position = target + (camera.global_position - target).normalized() * 30.0
