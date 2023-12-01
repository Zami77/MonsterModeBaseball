class_name MatchManager
extends Node2D

@export var total_innings = 3
@export var outs_per_inning = 3
@export var inning: Inning

@onready var bases_manager: BasesManager = $BasesManager
@onready var pitch_swing_button: DefaultButton = $PitchSwingButton

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
	pitch_swing_button.pressed.connect(_on_pitch_swing_button_pressed)
	
	bases_manager.run_scored.connect(_on_run_scored)
	bases_manager.out.connect(_on_out)
	
	rng.randomize()

func setup(_home_team: MonsterTeam, _away_team: MonsterTeam) -> void:
	home_team = _home_team
	away_team = _away_team
	_setup_inning()

func _setup_inning() -> void:
	if inning.current_frame == InningFrame.TOP:
		batter = MonsterCharacterFactory.get_monster_character(away_team.get_next_at_bat())
		pitcher = MonsterCharacterFactory.get_monster_character(home_team.get_next_pitcher())
	elif inning.current_frame == InningFrame.BOTTOM:
		batter = MonsterCharacterFactory.get_monster_character(home_team.get_next_at_bat())
		pitcher = MonsterCharacterFactory.get_monster_character(away_team.get_next_pitcher())
	
	add_child(batter)
	batter.global_position = bases_manager.home_base.global_position
	batter.scale = Vector2(0.5, 0.5)
	batter.monster_card.card_state = MonsterCard.CardState.BATTER
	
	add_child(pitcher)
	pitcher.global_position = bases_manager.pitcher_mound.global_position
	pitcher.scale = Vector2(0.5, 0.5)
	pitcher.monster_card.card_state = MonsterCard.CardState.PITCHER

func _get_next_batter() -> void:
	if inning.current_frame == InningFrame.TOP:
		batter = MonsterCharacterFactory.get_monster_character(away_team.get_next_at_bat())
	elif inning.current_frame == InningFrame.BOTTOM:
		batter = MonsterCharacterFactory.get_monster_character(home_team.get_next_at_bat())

	add_child(batter)
	batter.global_position = bases_manager.home_base.global_position
	batter.scale = Vector2(0.5, 0.5)
	batter.monster_card.card_state = MonsterCard.CardState.BATTER
	
func _execute_swing() -> void:
	match_state = MatchState.MID_PITCH_SWING
	
	var batter_roll = _roll_die()
	var pitcher_roll = _roll_die()
	
	var swing_result
	if batter_roll >= pitcher_roll:
		# batter advantage
		swing_result = batter.monster_card.evaluate_swing_result(batter_roll)
	else:
		swing_result = pitcher.monster_card.evaluate_swing_result(pitcher_roll)
	
	bases_manager.handle_swing_result(swing_result, batter)
	
	if inning.current_outs < outs_per_inning:
		_get_next_batter()
	
	match_state = MatchState.MID_MATCH

func _roll_die() -> int:
	return rng.randi_range(1, 20)

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
	
	if inning.current_inning > total_innings:
		_end_match()

func _on_pitch_swing_button_pressed() -> void:
	if match_state == MatchState.END_MATCH or match_state == MatchState.MID_PITCH_SWING:
		return
	_execute_swing()

func _on_run_scored(monster: MonsterCharacter) -> void:
	if inning.current_frame == InningFrame.TOP:
		away_team.score += 1
	elif inning.current_frame == InningFrame.BOTTOM:
		home_team.score += 1
	await get_tree().create_timer(1.0).timeout
	remove_child(monster)

func _on_out(monster: MonsterCharacter) -> void:
	inning.current_outs += 1
	remove_child(monster)
