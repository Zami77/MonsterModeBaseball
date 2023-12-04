class_name SpecialCard
extends Node2D

signal card_selected

@export var card_name: CardName
@export var pitcher_roll_modifier: int = 0
@export var batter_roll_modifier: int = 0

@onready var card_text_label: Label = $CardTextLabel
@onready var selectable_area: Area2D = $SelectableArea2D

enum CardName {
	PITCHER_PLUS_TWO,
	PITCHER_PLUS_ONE_BATTER_MINUS_ONE,
	BATTER_PLUS_TWO,
	BATTER_PLUS_ONE_PITCHER_MINUS_ONE
}

func _ready():
	_setup_card_text()
	
	selectable_area.input_event.connect(_on_selectable_area_input_event)

func _setup_card_text() -> void:
	card_text_label.text = ""
	
	card_text_label.text += "Pitcher: %s\n" % [_determine_sign(pitcher_roll_modifier)]
	card_text_label.text += "Batter: %s\n" % [_determine_sign(batter_roll_modifier)]

func _determine_sign(modifier) -> String:
	if modifier >= 0:
		return "+%d" % [modifier]
	return "-%d" % [abs(modifier)]

func _on_selectable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		emit_signal("card_selected")
