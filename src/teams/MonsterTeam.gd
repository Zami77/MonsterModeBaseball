class_name MonsterTeam
extends Resource

@export var monster_characters: Array[MonsterCard.CardName]
var score: int = 0
var current_at_bat = 0
var current_pitcher = 0

func get_next_at_bat() -> MonsterCard.CardName:
	var monster_card_name = monster_characters[current_at_bat]
	current_at_bat += 1
	
	if current_at_bat >= len(monster_characters):
		current_at_bat = 0
	return monster_card_name

func get_next_pitcher() -> MonsterCard.CardName:
	var monster_card_name = monster_characters[current_pitcher]
	current_pitcher += 1
	
	if current_pitcher >= len(monster_characters):
		current_pitcher = 0
	return monster_card_name
