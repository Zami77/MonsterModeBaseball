class_name MatchManager
extends Node2D

signal monster_moved_to_position
signal special_card_moved_to_position
signal all_monsters_in_dug_out
signal back_to_main_menu

@export var total_innings: int = 3
@export var outs_per_inning: int = 3
@export var inning: Inning
@export var max_monster_modes: int = 1
@export var monster_roll_modifier: int = 10
@export var player_helper_modifier: int = 3

@onready var bases_manager: BasesManager = $BasesManager
@onready var pitch_swing_button: DefaultButton = $PitchSwingButton
@onready var at_bat_label: Label = $StatsPanel/GameStatsContainer/AtBatLabel
@onready var inning_label: Label = $StatsPanel/GameStatsContainer/InningLabel
@onready var outs_label: Label = $StatsPanel/GameStatsContainer/OutsLabel
@onready var score_label: Label = $StatsPanel/GameStatsContainer/ScoreLabel
@onready var special_card_hand: SpecialCardHandManager = $SpecialCardHandManager
@onready var end_match_panel: EndMatchPanel = $EndMatchPanel
@onready var monster_mode_button: DefaultButton = $MonsterModeButton

# home team bats in the bottom of the inning
var home_team: MonsterTeam
var away_team: MonsterTeam
var pitcher: MonsterCharacter
var batter: MonsterCharacter
var match_state: MatchState = MatchState.MID_MATCH
var rng = RandomNumberGenerator.new()
var special_card_selected: SpecialCardWrapper = null
var special_cards_moving: bool = false
var is_monster_mode: bool = false:
	set(value):
		is_monster_mode = value
		_setup_monster_mode()

var times_monster_mode_used: int = 0 :
	set(value):
		times_monster_mode_used = value
		
		if times_monster_mode_used >= max_monster_modes:
			monster_mode_button.disabled = true

enum InningFrame { TOP, BOTTOM }
enum MatchState { 
	MID_MATCH = 0, 
	MID_PITCH_SWING = 1, 
	END_MATCH = 2,
	BETWEEN_INNINGS = 3
}

func _ready() -> void:
	AudioManager._fadeout_bgm()
	AudioManager.play_match_theme()
	
	pitch_swing_button.pressed.connect(_on_pitch_swing_button_pressed)
	monster_mode_button.pressed.connect(_on_monster_mode_button_pressed)
	
	bases_manager.run_scored.connect(_on_run_scored)
	bases_manager.out.connect(_on_out)
	
	special_card_hand.card_selected.connect(_on_special_card_hand_card_selected)
	
	end_match_panel.back_to_main_menu.connect(_on_end_match_panel_back_to_main_menu)
	rng.randomize()
	
	end_match_panel.visible = false

func setup(_home_team: MonsterTeam, _away_team: MonsterTeam) -> void:
	home_team = _home_team
	away_team = _away_team
	_update_stats_container()
	_setup_inning()

func _draw_special_cards() -> void:
	for new_card_num in (special_card_hand.max_hand_size - len(special_card_hand.cards_in_hand)):
		var new_card = SpecialCardWrapperFactory.get_random_special_card_wrapper()
		new_card.global_position = bases_manager.dug_out.global_position
		add_child(new_card)
		new_card.scale = Dimensions.card_scale
		special_card_hand.add_card_to_hand(new_card)

func _setup_inning() -> void:
	match_state = MatchState.MID_MATCH
	special_card_selected = null
	_setup_pitch_swing_button()
	_get_next_batter()
	_get_next_pitcher()
	_draw_special_cards()
	
	AudioManager.play_umpire_play_ball()

func _setup_pitch_swing_button() -> void:
	if inning.current_frame == InningFrame.TOP:
		pitch_swing_button.text = "Pitch"
	else:
		pitch_swing_button.text = "Swing"

func _get_next_batter() -> void:
	if inning.current_frame == InningFrame.TOP:
		batter = MonsterCharacterFactory.get_monster_character(away_team.get_next_at_bat())
	elif inning.current_frame == InningFrame.BOTTOM:
		batter = MonsterCharacterFactory.get_monster_character(home_team.get_next_at_bat())

	add_child(batter)
	batter.global_position = bases_manager.home_base.global_position
	batter.scale = Dimensions.card_scale
	batter.monster_card.card_state = MonsterCard.CardState.BATTER

func _get_next_pitcher() -> void:
	if inning.current_frame == InningFrame.TOP:
		pitcher = MonsterCharacterFactory.get_monster_character(home_team.get_next_pitcher())
	elif inning.current_frame == InningFrame.BOTTOM:
		pitcher = MonsterCharacterFactory.get_monster_character(away_team.get_next_pitcher())

	add_child(pitcher)
	pitcher.global_position = bases_manager.pitcher_mound.global_position
	pitcher.scale = Dimensions.card_scale
	pitcher.monster_card.card_state = MonsterCard.CardState.PITCHER

func _execute_swing() -> void:
	match_state = MatchState.MID_PITCH_SWING
	
	var batter_roll = DiceRollHelper.roll_die()
	var pitcher_roll = DiceRollHelper.roll_die()
	
	# help player if they're losing
	if home_team.score < away_team.score:
		if inning.current_frame == InningFrame.TOP:
			pitcher_roll = clampi(pitcher_roll + player_helper_modifier, 1, 20)
		else:
			batter_roll = clampi(batter_roll + player_helper_modifier, 1, 20)
		
	
	if is_monster_mode:
		if inning.current_frame == InningFrame.TOP:
			pitcher_roll = clampi(pitcher_roll + monster_roll_modifier, 1, 20)
		else:
			batter_roll = clampi(batter_roll + monster_roll_modifier, 1, 20)
		
		times_monster_mode_used += 1
	
	print ("batter_roll: %d\tpitcher_roll: %d" % [batter_roll, pitcher_roll])
	
	bases_manager.pitcher_dice_chucker.chuck_dice(pitcher_roll)
	await bases_manager.pitcher_dice_chucker.value_shown
	
	bases_manager.batter_dice_chucker.chuck_dice(batter_roll)
	await bases_manager.batter_dice_chucker.value_shown
	
	if special_card_selected:
		special_card_selected.special_card.play_use_card_animations()
		
		var batter_modifier = special_card_selected.special_card.batter_roll_modifier
		var pitcher_modifier = special_card_selected.special_card.pitcher_roll_modifier
		
		if pitcher_modifier != 0:
			pitcher_roll += pitcher_modifier
			bases_manager.pitcher_dice_chucker.chuck_dice(pitcher_roll)
			await bases_manager.pitcher_dice_chucker.value_shown
		if batter_modifier != 0:
			batter_roll += batter_modifier
			bases_manager.batter_dice_chucker.chuck_dice(batter_roll)
			await bases_manager.batter_dice_chucker.value_shown
		
		if batter_modifier == 0 and pitcher_modifier == 0:
			await special_card_selected.special_card.card_used
		
		special_card_selected.queue_free()
		special_card_selected = null
			
	var swing_result
	if batter_roll > pitcher_roll:
		# batter advantage
		swing_result = batter.monster_card.evaluate_swing_result(batter_roll)
	else:
		swing_result = pitcher.monster_card.evaluate_swing_result(batter_roll)
	
	print("SwingResult: %s" % [MonsterCard.SwingResult.keys()[swing_result]])
	bases_manager.handle_swing_result(swing_result, batter)
	await bases_manager.swing_result_handled
	
	if inning.current_outs < outs_per_inning:
		_get_next_batter()
	
	match_state = MatchState.MID_MATCH
	is_monster_mode = false

func _end_match() -> void:
	match_state = MatchState.END_MATCH
	
	end_match_panel.visible = true
	
	if home_team.score > away_team.score:
		end_match_panel.winning_team_label.text = "Home Team Wins!"
	else:
		end_match_panel.winning_team_label.text = "Away Team Wins!"
		
	print("Home Team Score: %d" % [home_team.score])
	print("Away Team Score: %d" % [away_team.score])

func _next_frame() -> void:
	match_state = MatchState.BETWEEN_INNINGS
	if inning.current_frame == InningFrame.TOP:
		inning.current_frame = InningFrame.BOTTOM
	elif inning.current_frame == InningFrame.BOTTOM:
		inning.current_frame = InningFrame.TOP
		inning.current_inning += 1
	
	inning.current_outs = 0
	
	bases_manager.handle_next_frame()
	_move_monsters_to_dug_out()
	await all_monsters_in_dug_out
	
	if inning.current_inning > total_innings:
		_end_match()
	else:
		_setup_inning()
	
	
	_update_stats_container()

func _move_monster_to_position(monster_character: MonsterCharacter, target_pos: Vector2) -> void:
	var monster_move_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	monster_move_tween.tween_property(monster_character, "global_position", target_pos, 0.8)
	await monster_move_tween.finished
	emit_signal("monster_moved_to_position")

func _move_special_card_to_position(special_card: SpecialCardWrapper, target_pos: Vector2) -> void:
	var special_card_move_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	special_card_move_tween.tween_property(special_card, "global_position", target_pos, 0.8)
	await special_card_move_tween.finished
	emit_signal("special_card_moved_to_position")

func _on_pitch_swing_button_pressed() -> void:
	if not _is_valid_pitch_swing():
		return
		
	_execute_swing()

func _is_valid_pitch_swing() -> bool:
	return  (
		match_state == MatchState.MID_MATCH or
		special_cards_moving
	)

func _on_run_scored(monster: MonsterCharacter) -> void:
	if inning.current_frame == InningFrame.TOP:
		AudioManager.play_crowd_boo()
		away_team.score += 1
	elif inning.current_frame == InningFrame.BOTTOM:
		AudioManager.play_crowd_cheer()
		home_team.score += 1
	
	_update_stats_container()
	
	await get_tree().create_timer(1.0).timeout
	remove_child(monster)
	monster.queue_free()

func _on_out(monster: MonsterCharacter) -> void:
	inning.current_outs += 1
	remove_child(monster)
	monster.queue_free()
	
	if inning.current_outs >= outs_per_inning:
		_next_frame()
	
	_update_stats_container()

func _on_special_card_hand_card_selected(special_card: SpecialCardWrapper, _card_index: int) -> void:
	if special_cards_moving:
		return
	
	special_cards_moving = true
	special_card_hand.remove_card_from_hand(special_card)
	
	if inning.current_frame == InningFrame.TOP:
		_move_special_card_to_position(special_card, bases_manager.pitcher_special_card_position.global_position)
	else:
		_move_special_card_to_position(special_card, bases_manager.batter_special_card_position.global_position)
	
	await get_tree().create_timer(0.1).timeout # buffer to prevent soft lock
	
	if special_card_selected:
		special_card_hand.add_card_to_hand(special_card_selected)
		special_card_selected = null
		await special_card_hand.hand_setup
		
	special_card_selected = special_card
	await special_card_moved_to_position
	special_cards_moving = false

func _on_end_match_panel_back_to_main_menu() -> void:
	emit_signal("back_to_main_menu")

func _on_monster_mode_button_pressed() -> void:
	is_monster_mode = !is_monster_mode

func _setup_monster_mode() -> void:
	print("Monster Mode: %s" % [is_monster_mode])
	
	if inning.current_frame == InningFrame.TOP:
		pitcher.monster_card.toggle_monster_mode(is_monster_mode)
	else:
		batter.monster_card.toggle_monster_mode(is_monster_mode)

func _move_monsters_to_dug_out() -> void:
	var monsters_to_remove = []
	for child in get_children():
		if child is MonsterCharacter:
			monsters_to_remove.append(child)
			_move_monster_to_position(child, bases_manager.dug_out.global_position)
	for i in monsters_to_remove:
		await monster_moved_to_position
	for monster in monsters_to_remove:
		remove_child(monster)
		monster.queue_free()
	emit_signal("all_monsters_in_dug_out")

func _update_stats_container() -> void:
	at_bat_label.text = "At Bat: %s" % [
		MonsterTeam.TeamName.keys()[away_team.monster_team_name] if inning.current_frame == InningFrame.TOP 
		else MonsterTeam.TeamName.keys()[home_team.monster_team_name]]
	inning_label.text = "%s of Inning %d" % [InningFrame.keys()[inning.current_frame], inning.current_inning]
	outs_label.text = "Outs: %d" % [inning.current_outs]
	score_label.text = "Home: %d Away: %d" % [home_team.score, away_team.score]
