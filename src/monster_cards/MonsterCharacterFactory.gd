class_name MonsterCharacterFactory
extends Node

static func get_monster_character(card_name: MonsterCard.CardName) -> MonsterCharacter:
	match card_name:
		MonsterCard.CardName.SLAKS_SLUGGER:
			return ScenePaths.slaks_slugger_packed_scene.instantiate()
		MonsterCard.CardName.GLURM:
			return ScenePaths.glurm_packed_scene.instantiate()
		MonsterCard.CardName.PLOOG:
			return ScenePaths.ploog_packed_scene.instantiate()
		MonsterCard.CardName.ZEEG:
			return ScenePaths.zeeg_packed_scene.instantiate()
		_:
			return ScenePaths.slaks_slugger_packed_scene.instantiate()
