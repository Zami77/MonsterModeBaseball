class_name SpecialCardWrapperFactory
extends Node

static func get_special_card_wrapper(card_name: SpecialCard.CardName) -> SpecialCardWrapper:
	match card_name:
		SpecialCard.CardName.PITCHER_PLUS_TWO:
			return ScenePaths.pitcher_plus_two_packed_scene.instantiate()
		SpecialCard.CardName.PITCHER_PLUS_ONE_BATTER_MINUS_ONE:
			return ScenePaths.pitcher_plus_one_batter_minus_one_packed_scene.instantiate()
		SpecialCard.CardName.BATTER_PLUS_TWO:
			return ScenePaths.batter_plus_two_packed_scene.instantiate()
		SpecialCard.CardName.BATTER_PLUS_ONE_PITCHER_MINUS_ONE:
			return ScenePaths.batter_plus_one_pitcher_minus_one_packed_scene.instantiate()
		_:
			return ScenePaths.batter_plus_one_pitcher_minus_one_packed_scene.instantiate()

static func get_random_special_card_wrapper() -> SpecialCardWrapper:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	return get_special_card_wrapper(rng.randi_range(0, SpecialCard.CardName.keys().size() - 1))
