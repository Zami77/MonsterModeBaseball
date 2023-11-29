extends Node2D

@export var monster_name: String = "Monster"
@export var bat_boost: int = 1
@export var pitch_power: int = 1
@export var monster_texture: Texture
@export var pitch_result_card_resource: ResultCard
@export var bat_result_card_resource: ResultCard

var card_state: CardState = CardState.BATTER:
	set(value):
		card_state = value
		_card_state_updated()

var pitch_result_card: Dictionary = {}
var bat_result_card: Dictionary = {}

enum CardState { BATTER=0, PITCHER=1 }
enum SwingResult {
	STRIKE_OUT=0, 
	FLY_BALL=1, 
	GROUND_BALL_OUT=2, 
	SINGLE=3, 
	DOUBLE=4, 
	TRIPLE=5, 
	HOME_RUN=6
}

const NO_RANGE = -1

func _ready():
	if not pitch_result_card_resource or not bat_result_card_resource:
		push_error("You need a pitch AND bat result resource in the monster card")
		return
	
	_fill_result_card_dictionaries()
	
func _fill_result_card_dictionaries() -> void:
	pitch_result_card[SwingResult.STRIKE_OUT] = pitch_result_card_resource.strike_out_range
	pitch_result_card[SwingResult.FLY_BALL] = pitch_result_card_resource.fly_ball_range
	pitch_result_card[SwingResult.GROUND_BALL_OUT] = pitch_result_card_resource.ground_ball_out_range
	pitch_result_card[SwingResult.SINGLE] = pitch_result_card_resource.single_range
	pitch_result_card[SwingResult.DOUBLE] = pitch_result_card_resource.double_range
	pitch_result_card[SwingResult.TRIPLE] = pitch_result_card_resource.triple_range
	pitch_result_card[SwingResult.HOME_RUN] = pitch_result_card_resource.home_run_range

	bat_result_card[SwingResult.STRIKE_OUT] = bat_result_card_resource.strike_out_range
	bat_result_card[SwingResult.FLY_BALL] = bat_result_card_resource.fly_ball_range
	bat_result_card[SwingResult.GROUND_BALL_OUT] = bat_result_card_resource.ground_ball_out_range
	bat_result_card[SwingResult.SINGLE] = bat_result_card_resource.single_range
	bat_result_card[SwingResult.DOUBLE] = bat_result_card_resource.double_range
	bat_result_card[SwingResult.TRIPLE] = bat_result_card_resource.triple_range
	bat_result_card[SwingResult.HOME_RUN] = bat_result_card_resource.home_run_range

func _card_state_updated():
	pass

func evaluate_swing_result(swing_value: int) -> SwingResult:
	var result_card = bat_result_card
	
	if card_state == CardState.PITCHER:
		result_card = pitch_result_card
	
	for swing_result in result_card.keys():
		var range = bat_result_card
		var low_range = range[0]
		var high_range = range[1]
		
		if low_range == NO_RANGE or high_range == NO_RANGE:
			continue
		
		if swing_value >= low_range and swing_value <= high_range:
			return swing_result
	
	push_error("SwingResult not found in %s result card" % [CardState.keys()[card_state]])
	return SwingResult.STRIKE_OUT
