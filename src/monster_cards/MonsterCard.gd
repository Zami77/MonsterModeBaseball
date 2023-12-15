class_name MonsterCard
extends Node2D

signal shook

@export var monster_name: String = "Monster"
@export var bat_boost: int = 1
@export var pitch_power: int = 1
@export var monster_texture: Texture
@export var pitch_result_card_resource: ResultCard
@export var bat_result_card_resource: ResultCard

@onready var monster_art: TextureRect = $MonsterArt
@onready var monster_name_label: Label = $MonsterNameLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shader_animation_player: AnimationPlayer = $ShaderAnimationPlayer
@onready var selectable_area: Area2D = $SelectableArea
@onready var result_card_panel: ResultCardPanel = $ResultCardPanel

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
enum CardName {
	SLAKS_SLUGGER = 0,
	GLURM = 1,
	PLOOG = 2,
	ZEEG = 3,
	GAN = 4,
	SNAX = 5,
	SNOTT = 6,
	UKO = 7
}

const NO_RANGE = -1

func _ready():
	if not pitch_result_card_resource or not bat_result_card_resource:
		push_error("You need a pitch AND bat result resource in the monster card")
		return
	
	monster_art.texture = monster_texture
	monster_name_label.text = monster_name
	
	selectable_area.mouse_entered.connect(_on_selectable_area_mouse_entered)
	selectable_area.mouse_exited.connect(_on_selectable_area_mouse_exited)

	result_card_panel.visible = false
	# animation_player.play("monster_art_idle")
	
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

func shake() -> void:
	animation_player.play("shake")
	await animation_player.animation_finished
	emit_signal("shook")

func evaluate_swing_result(swing_value: int) -> SwingResult:
	swing_value = clampi(swing_value, 1, 20)
	
	var result_card = bat_result_card
	
	if card_state == CardState.PITCHER:
		result_card = pitch_result_card
	
	for swing_result in result_card.keys():
		var swing_result_range = result_card[swing_result]
		var low_range = swing_result_range[0]
		var high_range = swing_result_range[1]
		
		if low_range == NO_RANGE or high_range == NO_RANGE:
			continue
		
		if swing_value >= low_range and swing_value <= high_range:
			return swing_result
	
	push_error("SwingResult not found in %s result card" % [CardState.keys()[card_state]])
	return SwingResult.STRIKE_OUT

func toggle_monster_mode(is_monster_mode: bool) -> void:
	if is_monster_mode:
		shader_animation_player.play("monster_mode_on")
	else:
		shader_animation_player.play("monster_mode_off")

func _on_selectable_area_mouse_entered() -> void:
	var result_card = bat_result_card
	
	if card_state == CardState.PITCHER:
		result_card = pitch_result_card
	
	result_card_panel.update_results_label(result_card)
	result_card_panel.visible = true

func play_idle_animation() -> void:
	animation_player.play("monster_art_idle")

func stop_animation() -> void:
	animation_player.stop()

func _on_selectable_area_mouse_exited() -> void:
	result_card_panel.visible = false
