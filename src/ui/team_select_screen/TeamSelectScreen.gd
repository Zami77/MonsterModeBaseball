class_name TeamSelectScreen
extends Node2D

signal team_selected(monster_team_selected)

@onready var selectable_teams_container: HBoxContainer = $SelectableTeamsContainer

func _ready():
	for child in selectable_teams_container.get_children():
		if child is SelectableTeam:
			child.team_selected.connect(_on_team_selected)


func _on_team_selected(monster_team: MonsterTeam) -> void:
	emit_signal("team_selected", monster_team)
