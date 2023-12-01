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
var match_state: MatchState = MatchState.MID_MATCH

enum InningFrame { TOP, BOTTOM }
enum MatchState { MID_MATCH, MID_PITCH_SWING, END_MATCH}

func _ready() -> void:
	pitch_swing_button.pressed.connect(_on_pitch_swing_button_pressed)

func setup(_home_team: MonsterTeam, _away_team: MonsterTeam) -> void:
	home_team = _home_team
	away_team = _away_team

func _setup_inning() -> void:
	# TODO: set up pitcher and batter by grabbing next from MonsterTeam
	pass

func _execute_swing() -> void:
	match_state = MatchState.MID_PITCH_SWING

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
