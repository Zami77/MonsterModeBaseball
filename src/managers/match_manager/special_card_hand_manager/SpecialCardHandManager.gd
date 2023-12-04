class_name SpecialCardHandManager
extends Node2D

signal card_selected(selected_card, card_index)
signal hand_setup
signal special_card_moved_to_position

@export var max_hand_size: int = 3
@export var cards_in_hand_buffer: int = 16
@export var speed_cards_move_in_pixels: int = 600

var cards_in_hand: Array[SpecialCardWrapper] = []

func add_card_to_hand(special_card: SpecialCardWrapper) -> void:
	if len(cards_in_hand) >= max_hand_size:
		return
	
	cards_in_hand.append(special_card)

	if not special_card.card_selected.is_connected(_on_card_selected):
		special_card.card_selected.connect(_on_card_selected.bind(special_card, len(cards_in_hand) - 1))
	
	_setup_hand()

func _setup_hand() -> void:
	for i in len(cards_in_hand):
		_move_card_to_hand_position(cards_in_hand[i], i)
		await special_card_moved_to_position
	emit_signal("hand_setup")

func _move_card_to_hand_position(special_card: SpecialCardWrapper, card_index: int) -> void:
	var target_hand_position = global_position + Vector2(card_index * Dimensions.card_dimensions.x * Dimensions.card_scale.x, 0)
	var time_to_move = special_card.global_position.distance_to(target_hand_position) / speed_cards_move_in_pixels
	
	time_to_move = clampf(time_to_move, 0.1, 1.0)
	
	var monster_move_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	monster_move_tween.tween_property(
		special_card, 
		"global_position", 
		target_hand_position, 
		time_to_move
	)
	await monster_move_tween.finished
	emit_signal("special_card_moved_to_position")

func remove_card_from_hand(special_card: SpecialCardWrapper) -> void:
	cards_in_hand.erase(special_card)
	special_card.card_selected.disconnect(_on_card_selected)
	_setup_hand()

func _on_card_selected(card: SpecialCardWrapper, card_index: int) -> void:
	emit_signal("card_selected", card, card_index)
	
