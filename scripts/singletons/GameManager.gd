extends Node

signal game_started
signal game_paused
signal game_resumed
signal level_completed

var current_level: int = 1
var game_state: GameState = GameState.MENU
var selected_heroes: Array[HeroData] = []
var player_data: PlayerData

enum GameState {
	MENU,
	BATTLE_PREP,
	COMBAT,
	PAUSED,
	GAME_OVER,
	VICTORY
}

class_name GameManager

func _ready():
	# Initialize game systems
	player_data = PlayerData.new()
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_new_game():
	current_level = 1
	game_state = GameState.BATTLE_PREP
	selected_heroes.clear()
	game_started.emit()

func pause_game():
	if game_state == GameState.COMBAT:
		game_state = GameState.PAUSED
		get_tree().paused = true
		game_paused.emit()

func resume_game():
	if game_state == GameState.PAUSED:
		game_state = GameState.COMBAT
		get_tree().paused = false
		game_resumed.emit()

func complete_level():
	game_state = GameState.VICTORY
	current_level += 1
	level_completed.emit()

func game_over():
	game_state = GameState.GAME_OVER
	get_tree().paused = true

func add_hero_to_party(hero: HeroData):
	if selected_heroes.size() < 8:  # Max party size
		selected_heroes.append(hero)

func remove_hero_from_party(hero: HeroData):
	selected_heroes.erase(hero)

func get_party_synergy_bonus() -> float:
	# Calculate synergy bonuses based on party composition
	var bonus: float = 1.0
	# Implementation for different class combinations
	return bonus
