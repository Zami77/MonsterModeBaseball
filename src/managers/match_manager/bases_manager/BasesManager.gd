class_name BasesManager
extends Node2D

signal run_scored(monster: MonsterCharacter)
signal out(monster: MonsterCharacter)
signal swing_result_handled
signal monster_moved_to_base

@onready var home_base: Node2D = $HomeBase
@onready var first_base: Node2D = $FirstBase
@onready var second_base: Node2D = $SecondBase
@onready var third_base: Node2D = $ThirdBase
@onready var pitcher_mound: Node2D = $PitcherMound
@onready var dug_out: Node2D = $DugOut
@onready var pitcher_dice_chucker: DiceChucker = $PitcherMound/PitcherDiceChucker
@onready var batter_dice_chucker: DiceChucker = $HomeBase/BatterDiceChucker
@onready var batter_special_card_position: Node2D = $HomeBase/BatterSpecialCard
@onready var pitcher_special_card_position: Node2D = $PitcherMound/PitcherSpecialCard

enum BasePlate { HOME = 4, AT_BAT = 0, FIRST = 1, SECOND = 2, THIRD = 3, DUG_OUT = 5 }

var base_layout: Array[MonsterCharacter] = [
	null, # AT_BAT
	null, # FIRST
	null, # SECOND
	null, # THIRD
	null  # HOME
]
var monsters_to_await = 0

func handle_next_frame() -> void:
	base_layout = [
		null, # AT_BAT
		null, # FIRST
		null, # SECOND
		null, # THIRD
		null  # HOME
	]

func handle_swing_result(swing_result: MonsterCard.SwingResult, at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = at_bat
	AudioManager.play_throw_ball()
	await get_tree().create_timer(0.1).timeout
	
	match swing_result:
		MonsterCard.SwingResult.STRIKE_OUT:
			_handle_strike_out(at_bat)
		MonsterCard.SwingResult.FLY_BALL:
			_handle_fly_ball(at_bat)
		MonsterCard.SwingResult.GROUND_BALL_OUT:
			_handle_ground_ball_out(at_bat)
		MonsterCard.SwingResult.SINGLE:
			_handle_single()
		MonsterCard.SwingResult.DOUBLE:
			_handle_double()
		MonsterCard.SwingResult.TRIPLE:
			_handle_triple()
		MonsterCard.SwingResult.HOME_RUN:
			_handle_home_run()

func _handle_strike_out(at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = null
	
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_catch_ball()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_strike_out()
	await get_tree().create_timer(0.1).timeout
	
	at_bat.monster_card.shake()
	await at_bat.monster_card.shook
	_move_monster_to_base(BasePlate.DUG_OUT, at_bat)
	await monster_moved_to_base
	emit_signal("swing_result_handled")
	emit_signal("out", at_bat)

func _handle_fly_ball(at_bat: MonsterCharacter) -> void:
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_catch_ball()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_out()
	await get_tree().create_timer(0.1).timeout
	
	base_layout[BasePlate.AT_BAT] = null
	at_bat.monster_card.shake()
	await at_bat.monster_card.shook
	_move_monster_to_base(BasePlate.DUG_OUT, at_bat)
	await monster_moved_to_base
	emit_signal("swing_result_handled")
	emit_signal("out", at_bat)

func _handle_ground_ball_out(at_bat: MonsterCharacter) -> void:
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_catch_ball()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_out()
	await get_tree().create_timer(0.1).timeout
	
	base_layout[BasePlate.AT_BAT] = null
	at_bat.monster_card.shake()
	await at_bat.monster_card.shook
	_move_monster_to_base(BasePlate.DUG_OUT, at_bat)
	await monster_moved_to_base
	emit_signal("swing_result_handled")
	emit_signal("out", at_bat)

func _handle_single() -> void:
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_ball_hit()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_safe()
	await get_tree().create_timer(0.1).timeout
	
	for base_plate in BasePlate.FIRST:
		monsters_to_await = 0
		_advance_base(base_plate)
		for i in monsters_to_await:
			await monster_moved_to_base
	emit_signal("swing_result_handled")

func _handle_double() -> void:
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_ball_hit()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_safe()
	await get_tree().create_timer(0.1).timeout
	
	for base_plate in BasePlate.SECOND:
		monsters_to_await = 0
		_advance_base(base_plate)
		for i in monsters_to_await:
			await monster_moved_to_base
	emit_signal("swing_result_handled")

func _handle_triple() -> void:
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_ball_hit()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_safe()
	await get_tree().create_timer(0.1).timeout
	
	for base_plate in BasePlate.THIRD:
		monsters_to_await = 0
		_advance_base(base_plate)
		for i in monsters_to_await:
			await monster_moved_to_base
	emit_signal("swing_result_handled")

func _handle_home_run() -> void:
	AudioManager.play_bat_swing()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_ball_hit()
	await get_tree().create_timer(0.1).timeout
	
	AudioManager.play_umpire_safe()
	await get_tree().create_timer(0.1).timeout
	
	for base_plate in BasePlate.HOME:
		monsters_to_await = 0
		_advance_base(base_plate)
		for i in monsters_to_await:
			await monster_moved_to_base
	emit_signal("swing_result_handled")

func _advance_base(current_base: BasePlate) -> void:
	if current_base >= BasePlate.HOME:
		return
	
	var monster_on_base: MonsterCharacter = base_layout[current_base]
	
	if current_base == BasePlate.THIRD:
		emit_signal("run_scored", monster_on_base)
	
	if base_layout[current_base + 1]:
		_advance_base(current_base + 1)
	monsters_to_await += 1
	_move_monster_to_base(current_base + 1, monster_on_base)
	AudioManager.play_running_base()
	base_layout[current_base] = null
	base_layout[current_base + 1] = monster_on_base

	
func _move_monster_to_base(base_to_move_to: BasePlate, monster_character: MonsterCharacter) -> void:
	var monster_move_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	monster_move_tween.tween_property(monster_character, "position", _get_global_position_of_base_plate(base_to_move_to), 0.8)
	await monster_move_tween.finished
	emit_signal("monster_moved_to_base")

func _get_global_position_of_base_plate(base_plate: BasePlate) -> Vector2:
	match base_plate:
		BasePlate.HOME, BasePlate.AT_BAT:
			return home_base.global_position
		BasePlate.FIRST:
			return first_base.global_position
		BasePlate.SECOND:
			return second_base.global_position
		BasePlate.THIRD:
			return third_base.global_position
		BasePlate.DUG_OUT:
			return dug_out.global_position
		_:
			return home_base.global_position
