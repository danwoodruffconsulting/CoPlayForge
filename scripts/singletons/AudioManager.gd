extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var current_music: AudioStream
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

class_name AudioManager

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create pool of SFX players
	for i in range(10):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

func play_music(music: AudioStream, fade_in: bool = true):
	if current_music == music and music_player.playing:
		return
	
	current_music = music
	
	if fade_in and music_player.playing:
		# Fade out current music, then fade in new music
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 0.5)
		tween.tween_callback(func(): 
			music_player.stream = music
			music_player.play()
			music_player.volume_db = -80
		)
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), 0.5)
	else:
		music_player.stream = music
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()

func stop_music(fade_out: bool = true):
	if fade_out:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 0.5)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()

func play_sfx(sound: AudioStream, volume_modifier: float = 1.0):
	var available_player = get_available_sfx_player()
	if available_player:
		available_player.stream = sound
		available_player.volume_db = linear_to_db(sfx_volume * volume_modifier)
		available_player.play()

func get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# If all players are busy, use the first one
	return sfx_players[0]

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

# Chiptune-style audio effects
func play_combat_sfx(effect_type: String):
	match effect_type:
		"sword_hit":
			play_sfx(preload("res://audio/sfx/sword_hit.ogg"))
		"magic_cast":
			play_sfx(preload("res://audio/sfx/magic_cast.ogg"))
		"bow_shot":
			play_sfx(preload("res://audio/sfx/bow_shot.ogg"))
		"heal":
			play_sfx(preload("res://audio/sfx/heal.ogg"))
		"death":
			play_sfx(preload("res://audio/sfx/death.ogg"))
		"level_up":
			play_sfx(preload("res://audio/sfx/level_up.ogg"))
		_:
			print("Unknown SFX type: ", effect_type)
