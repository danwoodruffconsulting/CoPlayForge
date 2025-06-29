extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var player_units_container: Node3D = $Battlefield/PlayerUnits
@onready var enemy_units_container: Node3D = $Battlefield/EnemyUnits
@onready var ui: Control = $UI/MainUI
@onready var turn_display: Label = $UI/MainUI/HUD/TurnDisplay
@onready var unit_info_panel: Panel = $UI/MainUI/UnitInfo

var selected_unit: Unit
var camera_controller: CameraController

func _ready():
	print("CoPlayForge: Initializing tactical RPG...")
	create_battlefield()
	setup_camera_controller()
	setup_ui_connections()
	start_demo_battle()

func create_battlefield():
	print("Creating battlefield...")
	# Create a ground plane
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(20, 12)
	ground.mesh = plane_mesh
	
	# Create ground material
	var ground_material = StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.4, 0.6, 0.4)
	ground_material.roughness = 0.8
	ground_material.metallic = 0.0
	ground.material_override = ground_material
	
	# Add ground collision
	var ground_body = StaticBody3D.new()
	var ground_collision = CollisionShape3D.new()
	var ground_shape = BoxShape3D.new()
	ground_shape.size = Vector3(20, 0.1, 12)
	ground_collision.shape = ground_shape
	ground_body.add_child(ground_collision)
	ground_body.position = Vector3(0, -0.05, 0)
	
	$Battlefield.add_child(ground)
	$Battlefield.add_child(ground_body)

func setup_camera_controller():
	camera_controller = CameraController.new()
	camera_controller.setup(camera)

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
	print("Starting demo battle...")
	# Create demo hero data
	var player_heroes: Array[HeroData] = []
	var enemy_data: Array[EnemyData] = []
	
	# Create test heroes
	for i in range(3):
		var hero = HeroData.new()
		hero.hero_name = "Hero " + str(i + 1)
		hero.hero_class = HeroClass.Type.values()[i % 5]
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
	print("Spawning units...")
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
	
	# Create tactical formation positions
	var formation_positions = []
	if is_player:
		formation_positions = [
			Vector3(-2, 0, -3),
			Vector3(0, 0, -3),
			Vector3(2, 0, -3),
			Vector3(-1, 0, -4),
			Vector3(1, 0, -4)
		]
	else:
		formation_positions = [
			Vector3(-1, 0, 3),
			Vector3(1, 0, 3),
			Vector3(-2, 0, 4),
			Vector3(0, 0, 4),
			Vector3(2, 0, 4)
		]
	
	# Position unit in formation
	if index < formation_positions.size():
		unit.global_position = formation_positions[index]
	else:
		var row = index / 3
		var col = index % 3
		var base_z = -3 if is_player else 3
		unit.global_position = Vector3((col - 1) * 2, 0, base_z + row * 1)
	
	container.add_child(unit)
	unit.unit_died.connect(_on_unit_died)
	setup_unit_input(unit)

func setup_unit_input(unit: Unit):
	unit.unit_clicked.connect(_on_unit_clicked)

func _on_unit_clicked(unit: Unit):
	if unit.is_player_controlled:
		select_unit(unit)
	elif selected_unit:
		initiate_attack(selected_unit, unit)

func select_unit(unit: Unit):
	if selected_unit:
		deselect_unit(selected_unit)
	
	selected_unit = unit
	highlight_unit(unit)
	update_unit_info_panel(unit)

func deselect_unit(unit: Unit):
	remove_unit_highlight(unit)

func highlight_unit(unit: Unit):
	if unit.mesh_instance:
		var highlight_material = StandardMaterial3D.new()
		highlight_material.albedo_color = Color.YELLOW
		highlight_material.emission_enabled = true
		highlight_material.emission = Color.YELLOW * 0.3
		unit.mesh_instance.material_override = highlight_material

func remove_unit_highlight(unit: Unit):
	if unit.mesh_instance:
		unit.mesh_instance.material_override = null

func update_unit_info_panel(unit: Unit):
	if unit.hero_data:
		print("Selected: " + unit.hero_data.hero_name + " (Level " + str(unit.hero_data.level) + ")")
		var stats = unit.get_total_stats()
		print("HP: " + str(unit.current_health) + "/" + str(stats.health))
		print("ATK: " + str(stats.attack) + " DEF: " + str(stats.defense))

func initiate_attack(attacker: Unit, target: Unit):
	if attacker and target and attacker != target:
		print(attacker.hero_data.hero_name + " attacks " + (target.hero_data.hero_name if target.hero_data else "Enemy"))
		attacker.attack_target(target)

func _on_turn_changed(current_player: String):
	turn_display.text = "Turn: " + current_player

func _on_combat_ended(winner: String):
	print("Combat ended! Winner: " + winner)

func _on_unit_died(unit: Unit):
	print("Unit died: ", unit.hero_data.hero_name if unit.hero_data else "Enemy")

func _on_attack_button_pressed():
	if selected_unit and selected_unit.hero_data:
		print("Attack mode activated for " + selected_unit.hero_data.hero_name)

func _on_defend_button_pressed():
	if selected_unit and selected_unit.hero_data:
		print(selected_unit.hero_data.hero_name + " defends")

func _on_ability_button_pressed():
	if selected_unit and selected_unit.hero_data:
		print("Ability menu for " + selected_unit.hero_data.hero_name)

func _on_end_turn_button_pressed():
	CombatManager.end_turn()
	print("Turn ended")

func _input(event):
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
			var target = Vector3.ZERO
			
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
