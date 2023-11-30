class_name BasesManager
extends Node2D

signal run_scored
signal swing_result_handled

@onready var home_base: Node2D = $HomeBase
@onready var first_base: Node2D = $FirstBase
@onready var second_base: Node2D = $SecondBase
@onready var third_base: Node2D = $ThirdBase

enum BasePlate { HOME = 4, AT_BAT = 0, FIRST = 1, SECOND = 2, THIRD = 3 }

var base_layout: Array[MonsterCharacter] = [
	null,
	null,
	null,
	null,
	null
]

func handle_swing_result(swing_result: MonsterCard.SwingResult, at_bat: MonsterCharacter) -> void:
	base_layout[BasePlate.AT_BAT] = at_bat
	match swing_result:
		MonsterCard.SwingResult.STRIKE_OUT:
			_handle_strike_out()
		MonsterCard.SwingResult.FLY_BALL:
			_handle_fly_ball()
		MonsterCard.SwingResult.GROUND_BALL_OUT:
			_handle_ground_ball_out()
		MonsterCard.SwingResult.SINGLE:
			_handle_single()
		MonsterCard.SwingResult.DOUBLE:
			_handle_double()
		MonsterCard.SwingResult.TRIPLE:
			_handle_triple()
		MonsterCard.SwingResult.HOME_RUN:
			_handle_home_run()
	
	emit_signal("swing_result_handled")

func _handle_strike_out() -> void:
	base_layout[BasePlate.AT_BAT] = null

func _handle_fly_ball() -> void:
	base_layout[BasePlate.AT_BAT] = null

func _handle_ground_ball_out() -> void:
	base_layout[BasePlate.AT_BAT] = null

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
		emit_signal("run_scored")
	
	if base_layout[current_base + 1]:
		_advance_base(current_base + 1)
	
	base_layout[current_base] = null
	base_layout[current_base + 1] = monster_on_base
	# TODO: add tween animation from base to base
	
