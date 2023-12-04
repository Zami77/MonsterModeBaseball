class_name SpecialCardWrapper
extends Node2D

signal card_selected

@onready var special_card: SpecialCard = $SpecialCard

func _ready() -> void:
	special_card.card_selected.connect(_on_card_selected)

func _on_card_selected() -> void:
	emit_signal("card_selected")
