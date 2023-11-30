class_name MonsterCharacterFactory
extends Node

static func get_monster_character(card_name: MonsterCard.CardName) -> MonsterCharacter:
	match card_name:
		MonsterCard.CardName.SlaksSlugger:
			return ScenePaths.slaks_slugger_packed_scene.instantiate()
		_:
			return ScenePaths.slaks_slugger_packed_scene.instantiate()
