class_name SelectableTeam
extends Node2D

signal team_selected(monster_team_selected: MonsterTeam.TeamName)

@export var monster_team_name: MonsterTeam.TeamName

@onready var monster_team_name_label: Label = $MonsterTeamNameLabel
@onready var select_team_button: DefaultButton = $SelectTeamButton

func _ready():
	monster_team_name_label.text = MonsterTeam.get_monster_team_name_decorative(monster_team_name)
	select_team_button.pressed.connect(_on_select_team_button_pressed)

func _on_select_team_button_pressed() -> void:
	emit_signal("team_selected", monster_team_name)
