class_name MonsterTeamFactory
extends Node

static func get_monster_team(team_name: MonsterTeam.TeamName) -> Resource:
	match team_name:
		MonsterTeam.TeamName.GOBLIN_TEAM:
			return ScenePaths.goblin_team_resource
		_:
			return ScenePaths.goblin_team_resource
