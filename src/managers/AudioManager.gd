extends Node

enum BgmPlaying { MAIN_MENU, MATCH, NONE }

var num_players = 16
static var bus_master = "Master"
static var bus_sound_effects = "SoundEffects"
static var bus_music = "Music"

var bgm_player = AudioStreamPlayer.new()
var bgm_playing = BgmPlaying.NONE
var available_players = []  
var sfx_queue = []  

var rng = RandomNumberGenerator.new()

var button_press = "res://src/ui/default_button/Click Plastic.wav"
var button_hover = "res://src/ui/default_button/button_hover.wav"

var main_menu_songs = [
	"res://src/common/music/Ambient Exploration Main.wav"
]
var main_menu_bag = []

var match_songs = [
	"res://src/common/music/HipHop Old Skool Main.wav"
]
var match_songs_bag = []

var throw_ball_sfx = [
	"res://src/common/sfx/throw_ball/Throw Ball_1.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_2.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_3.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_4.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_5.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_6.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_7.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_8.wav", 
	"res://src/common/sfx/throw_ball/Throw Ball_9.wav"
]
var throw_ball_bag = []

var ball_hit_sfx = [
	"res://src/common/sfx/ball_hit/Ball Hit_1.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_2.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_3.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_4.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_5.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_6.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_7.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_8.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_9.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_10.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_11.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_12.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_13.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_14.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_15.wav", 
	"res://src/common/sfx/ball_hit/Ball Hit_16.wav"
]
var ball_hit_bag = []

var catch_ball_sfx = [
	"res://src/common/sfx/catch_ball/Catch Ball_1.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_2.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_3.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_4.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_5.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_6.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_7.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_8.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_9.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_10.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_11.wav", 
	"res://src/common/sfx/catch_ball/Catch Ball_12.wav"
]
var catch_ball_bag = []

var bat_swing_sfx = [
	"res://src/common/sfx/bat_swing/Bat Swing_1.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_2.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_3.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_4.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_5.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_6.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_7.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_8.wav", 
	"res://src/common/sfx/bat_swing/Bat Swing_9.wav"
]
var bat_swing_bag = []

var slide_sfx = [
	"res://src/common/sfx/slide/Slide_1.wav", 
	"res://src/common/sfx/slide/Slide_2.wav", 
	"res://src/common/sfx/slide/Slide_3.wav", 
	"res://src/common/sfx/slide/Slide_4.wav", 
	"res://src/common/sfx/slide/Slide_5.wav", 
	"res://src/common/sfx/slide/Slide_6.wav", 
	"res://src/common/sfx/slide/Slide_7.wav", 
	"res://src/common/sfx/slide/Slide_8.wav", 
	"res://src/common/sfx/slide/Slide_9.wav", 
	"res://src/common/sfx/slide/Slide_10.wav"
]
var slide_bag = []

var running_bases_sfx = [
	"res://src/common/sfx/running_bases/Running Bases_1.wav", 
	"res://src/common/sfx/running_bases/Running Bases_2.wav", 
	"res://src/common/sfx/running_bases/Running Bases_3.wav", 
	"res://src/common/sfx/running_bases/Running Bases_4.wav", 
	"res://src/common/sfx/running_bases/Running Bases_5.wav", 
	"res://src/common/sfx/running_bases/Running Bases_6.wav", 
	"res://src/common/sfx/running_bases/Running Bases_7.wav", 
	"res://src/common/sfx/running_bases/Running Bases_8.wav", 
	"res://src/common/sfx/running_bases/Running Bases_9.wav"
]
var running_bases_bag = []

var crowd_cheers_sfx = [
	"res://src/common/sfx/crowd_cheer/Crowd Cheer_3.wav", 
	"res://src/common/sfx/crowd_cheer/Crowd Cheer_6.wav"
]
var crowd_cheers_bag = []

var crowd_boos_sfx = [
	"res://src/common/sfx/crowd_boo/Crowd Boo_1.wav", 
	"res://src/common/sfx/crowd_boo/Crowd Boo_2.wav", 
	"res://src/common/sfx/crowd_boo/Crowd Boo_3.wav", 
	"res://src/common/sfx/crowd_boo/Crowd Boo_4.wav", 
	"res://src/common/sfx/crowd_boo/Crowd Boo_5.wav"
]
var crowd_boos_bag = []

var umpire_strike_out_sfx = "res://src/common/sfx/umpire/Umpire_5.wav"
var umpire_play_ball_sfx = "res://src/common/sfx/umpire/Umpire_2.wav"
var umpire_out_sfx = "res://src/common/sfx/umpire/Umpire_1.wav"
var umpire_safe_sfx = "res://src/common/sfx/umpire/Umpire_8.wav"

var dice_roll_sfx = "res://src/dice_chucker/Roll 1d20.wav"

func _ready():
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available_players.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus_sound_effects
	
	bgm_player.bus = bus_music
	bgm_player.finished.connect(_on_bgm_player_finished)
	add_child(bgm_player)
		
	rng.randomize()

func _on_stream_finished(stream) -> void:
	stream.stop()
	available_players.append(stream)

func _on_bgm_player_finished():
	match bgm_playing:
		BgmPlaying.MAIN_MENU:
			bgm_playing = BgmPlaying.NONE
			play_menu_theme()
		BgmPlaying.MATCH:
			bgm_playing = BgmPlaying.NONE
			play_match_theme()

func play_bgm(sound_path):
	_fadeout_bgm()
	bgm_player.stream = load(sound_path)
	bgm_player.play()

func play_sfx(sound_path):
	sfx_queue.append(sound_path)

func play_menu_theme() -> void:
	if bgm_playing == BgmPlaying.MAIN_MENU:
		return
	
	_fill_bags()
	bgm_playing = BgmPlaying.MAIN_MENU
	play_bgm(main_menu_bag.pop_at(rng.randi_range(0, len(main_menu_bag) - 1)))

func play_match_theme() -> void:
	if bgm_playing == BgmPlaying.MATCH:
		return
	
	_fill_bags()
	bgm_playing = BgmPlaying.MATCH
	play_bgm(match_songs_bag.pop_at(rng.randi_range(0, len(match_songs_bag) - 1)))

func _fadeout_bgm():
	bgm_player.stop()

func play_button_press() -> void:
	play_sfx(button_press)

func play_button_hover() -> void:
	play_sfx(button_hover)

func play_throw_ball() -> void:
	_fill_bags()
	play_sfx(throw_ball_bag.pop_at(rng.randi_range(0, len(throw_ball_bag) - 1)))

func play_catch_ball() -> void:
	_fill_bags()
	play_sfx(catch_ball_bag.pop_at(rng.randi_range(0, len(catch_ball_bag) - 1)))

func play_bat_swing() -> void:
	_fill_bags()
	play_sfx(bat_swing_bag.pop_at(rng.randi_range(0, len(bat_swing_bag) - 1)))

func play_ball_hit() -> void:
	_fill_bags()
	play_sfx(ball_hit_bag.pop_at(rng.randi_range(0, len(ball_hit_bag) - 1)))

func play_running_base() -> void:
	_fill_bags()
	play_sfx(running_bases_bag.pop_at(rng.randi_range(0, len(running_bases_bag) - 1)))

func play_crowd_cheer() -> void:
	_fill_bags()
	play_sfx(crowd_cheers_bag.pop_at(rng.randi_range(0, len(crowd_cheers_bag) - 1)))

func play_crowd_boo() -> void:
	_fill_bags()
	play_sfx(crowd_boos_bag.pop_at(rng.randi_range(0, len(crowd_boos_bag) - 1)))

func play_umpire_strike_out() -> void:
	play_sfx(umpire_strike_out_sfx)

func play_umpire_safe() -> void:
	play_sfx(umpire_safe_sfx)

func play_umpire_out() -> void:
	play_sfx(umpire_out_sfx)

func play_umpire_play_ball() -> void:
	play_sfx(umpire_play_ball_sfx)

func play_dice_roll() -> void:
	play_sfx(dice_roll_sfx)
	
func _fill_bags() -> void:
	if not main_menu_bag:
		main_menu_bag = main_menu_songs.duplicate()
	if not match_songs_bag:
		match_songs_bag = match_songs.duplicate()
	if not throw_ball_bag:
		throw_ball_bag = throw_ball_sfx.duplicate()
	if not slide_bag:
		slide_bag = slide_sfx.duplicate()
	if not ball_hit_bag:
		ball_hit_bag = ball_hit_sfx.duplicate()
	if not bat_swing_bag:
		bat_swing_bag = bat_swing_sfx.duplicate()
	if not catch_ball_bag:
		catch_ball_bag = catch_ball_sfx.duplicate()
	if not crowd_cheers_bag:
		crowd_cheers_bag = crowd_cheers_sfx.duplicate()
	if not crowd_boos_bag:
		crowd_boos_bag = crowd_boos_sfx.duplicate()
	if not running_bases_bag:
		running_bases_bag = running_bases_sfx.duplicate()

func _process(_delta):
	if not sfx_queue.is_empty() and not available_players.is_empty():
		available_players[0].stream = load(sfx_queue.pop_front())
		available_players[0].play()
		available_players.pop_front()
