class_name SpecialCard
extends Node2D

@export var card_name: CardName
@export var pitcher_roll_modifier: int = 0
@export var batter_roll_modifier: int = -1

@onready var card_text_label: Label = $CardTextLabel

enum CardName {
	PITCHER_PLUS_TWO,
	PITCHER_PLUS_ONE_BATTER_MINUS_ONE,
	BATTER_PLUS_TWO,
	BATTER_PLUS_ONE_PITCHER_MINUS_ONE
}

func _ready():
	_setup_card_text()

func _setup_card_text() -> void:
	card_text_label.text = ""
	
	card_text_label.text += "Pitcher: %s\n" % [_determine_sign(pitcher_roll_modifier)]
	card_text_label.text += "Batter: %s\n" % [_determine_sign(batter_roll_modifier)]

func _determine_sign(modifier) -> String:
	if modifier >= 0:
		return "+%d" % [modifier]
	return "-%d" % [abs(modifier)]
