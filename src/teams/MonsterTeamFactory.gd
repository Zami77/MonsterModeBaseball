class_name MonsterTeamFactory
extends Node

static func get_monster_team(team_name: MonsterTeam.TeamName) -> Resource:
	match team_name:
		MonsterTeam.TeamName.GOBLIN_TEAM:
			return ScenePaths.goblin_team_resource.duplicate()
		MonsterTeam.TeamName.KOBOLD_TEAM:
			return ScenePaths.kobold_team_resource.duplicate()
		_:
			return ScenePaths.goblin_team_resource.duplicate()

const all_monster_teams = [
	MonsterTeam.TeamName.GOBLIN_TEAM, 
	MonsterTeam.TeamName.KOBOLD_TEAM
]
