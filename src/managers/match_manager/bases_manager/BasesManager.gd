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

enum BasePlate { HOME = 4, AT_BAT = 0, FIRST = 1, SECOND = 2, THIRD = 3 }

var base_layout: Array[MonsterCharacter] = [
	null, # AT_BAT
	null, # FIRST
	null, # SECOND
	null, # THIRD
	null  # HOME
]

func handle_swing_result(swing_result: MonsterCard.SwingResult, at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = at_bat
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
	
	emit_signal("swing_result_handled")

func _handle_strike_out(at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = null
	emit_signal("out", at_bat)

func _handle_fly_ball(at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = null
	emit_signal("out", at_bat)

func _handle_ground_ball_out(at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = null
	emit_signal("out", at_bat)

func _handle_single() -> void:
	for base_plate in BasePlate.FIRST:
		_advance_base(base_plate)

func _handle_double() -> void:
	for base_plate in BasePlate.SECOND:
		_advance_base(base_plate)

func _handle_triple() -> void:
	for base_plate in BasePlate.THIRD:
		_advance_base(base_plate)

func _handle_home_run() -> void:
	for base_plate in BasePlate.HOME:
		_advance_base(base_plate)

func _advance_base(current_base: BasePlate) -> void:
	if current_base >= BasePlate.HOME:
		
		return
	
	var monster_on_base: MonsterCharacter = base_layout[current_base]
	
	if current_base == BasePlate.THIRD:
		emit_signal("run_scored", monster_on_base)
	
	if base_layout[current_base + 1]:
		_advance_base(current_base + 1)
	
	_move_monster_to_base(current_base + 1, monster_on_base)
	
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
		_:
			return home_base.global_position
