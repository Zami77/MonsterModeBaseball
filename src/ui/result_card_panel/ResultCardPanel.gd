class_name ResultCardPanel
extends Node2D

@onready var results_label: Label = $Panel/VBoxContainer/ResultsLabel

func update_results_label(result_card: Dictionary) -> void:
	results_label.text = (
		"Strike Out: %s\n" +
		"Fly Ball Out: %s\n" +
		"Ground Ball Out: %s\n" +
		"Single: %s\n" +
		"Double: %s\n" +
		"Triple: %s\n" +
		"Home Run: %s"
	) % [
		_get_result_to_string(result_card[MonsterCard.SwingResult.STRIKE_OUT]),
		_get_result_to_string(result_card[MonsterCard.SwingResult.FLY_BALL]),
		_get_result_to_string(result_card[MonsterCard.SwingResult.GROUND_BALL_OUT]),
		_get_result_to_string(result_card[MonsterCard.SwingResult.SINGLE]),
		_get_result_to_string(result_card[MonsterCard.SwingResult.DOUBLE]),
		_get_result_to_string(result_card[MonsterCard.SwingResult.TRIPLE]),
		_get_result_to_string(result_card[MonsterCard.SwingResult.HOME_RUN])
	]

func _get_result_to_string(result_arr: Array) -> String:
	if result_arr[0] == -1:
		return "-"
	
	return "%d-%d" % [result_arr[0], result_arr[1]]
