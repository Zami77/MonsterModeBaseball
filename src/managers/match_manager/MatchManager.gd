class_name MatchManager
extends Node2D

signal monster_moved_to_position
signal all_monsters_in_dug_out

@export var total_innings = 3
@export var outs_per_inning = 3
@export var inning: Inning

@onready var bases_manager: BasesManager = $BasesManager
@onready var pitch_swing_button: DefaultButton = $PitchSwingButton
@onready var at_bat_label: Label = $StatsPanel/GameStatsContainer/AtBatLabel
@onready var inning_label: Label = $StatsPanel/GameStatsContainer/InningLabel
@onready var outs_label: Label = $StatsPanel/GameStatsContainer/OutsLabel
@onready var score_label: Label = $StatsPanel/GameStatsContainer/ScoreLabel

# home team bats in the bottom of the inning
var home_team: MonsterTeam
var away_team: MonsterTeam
var pitcher: MonsterCharacter
var batter: MonsterCharacter
var match_state: MatchState = MatchState.MID_MATCH
var rng = RandomNumberGenerator.new()

enum InningFrame { TOP, BOTTOM }
enum MatchState { MID_MATCH, MID_PITCH_SWING, END_MATCH}

func _ready() -> void:
	AudioManager._fadeout_bgm()
	pitch_swing_button.pressed.connect(_on_pitch_swing_button_pressed)
	
	bases_manager.run_scored.connect(_on_run_scored)
	bases_manager.out.connect(_on_out)
	
	rng.randomize()

func setup(_home_team: MonsterTeam, _away_team: MonsterTeam) -> void:
	home_team = _home_team
	away_team = _away_team
	_update_stats_container()
	_setup_inning()

func _setup_inning() -> void:
	_get_next_batter()
	_get_next_pitcher()

func _get_next_batter() -> void:
	if inning.current_frame == InningFrame.TOP:
		batter = MonsterCharacterFactory.get_monster_character(away_team.get_next_at_bat())
	elif inning.current_frame == InningFrame.BOTTOM:
		batter = MonsterCharacterFactory.get_monster_character(home_team.get_next_at_bat())

	add_child(batter)
	batter.global_position = bases_manager.home_base.global_position
	batter.scale = Vector2(0.5, 0.5)
	batter.monster_card.card_state = MonsterCard.CardState.BATTER

func _get_next_pitcher() -> void:
	if inning.current_frame == InningFrame.TOP:
		pitcher = MonsterCharacterFactory.get_monster_character(home_team.get_next_pitcher())
	elif inning.current_frame == InningFrame.BOTTOM:
		pitcher = MonsterCharacterFactory.get_monster_character(away_team.get_next_pitcher())

	add_child(pitcher)
	pitcher.global_position = bases_manager.pitcher_mound.global_position
	pitcher.scale = Vector2(0.5, 0.5)
	pitcher.monster_card.card_state = MonsterCard.CardState.PITCHER

func _execute_swing() -> void:
	match_state = MatchState.MID_PITCH_SWING
	
	var batter_roll = DiceRollHelper.roll_die()
	var pitcher_roll = DiceRollHelper.roll_die()
	print ("batter_roll: %d\tpitcher_roll: %d" % [batter_roll, pitcher_roll])
	
	bases_manager.pitcher_dice_chucker.chuck_dice(pitcher_roll)
	await bases_manager.pitcher_dice_chucker.value_shown
	
	bases_manager.batter_dice_chucker.chuck_dice(batter_roll)
	await bases_manager.batter_dice_chucker.value_shown
	
	var swing_result
	if batter_roll >= pitcher_roll:
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

func _end_match() -> void:
	match_state = MatchState.END_MATCH
	print("Home Team Score: %d" % [home_team.score])
	print("Away Team Score: %d" % [away_team.score])

func _next_frame() -> void:
	if inning.current_frame == InningFrame.TOP:
		inning.current_frame = InningFrame.BOTTOM
	elif inning.current_frame == InningFrame.BOTTOM:
		inning.current_frame = InningFrame.TOP
		inning.current_inning += 1
	
	inning.current_outs = 0
	
	bases_manager.handle_next_frame()
	_move_monsters_to_dug_out()
	await all_monsters_in_dug_out
	_setup_inning()
	
	if inning.current_inning > total_innings:
		_end_match()
	
	_update_stats_container()

func _move_monster_to_position(monster_character: MonsterCharacter, target_pos: Vector2) -> void:
	var monster_move_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	monster_move_tween.tween_property(monster_character, "global_position", target_pos, 0.8)
	await monster_move_tween.finished
	emit_signal("monster_moved_to_position")

func _on_pitch_swing_button_pressed() -> void:
	if match_state == MatchState.END_MATCH or match_state == MatchState.MID_PITCH_SWING:
		return
	_execute_swing()

func _on_run_scored(monster: MonsterCharacter) -> void:
	if inning.current_frame == InningFrame.TOP:
		away_team.score += 1
	elif inning.current_frame == InningFrame.BOTTOM:
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
