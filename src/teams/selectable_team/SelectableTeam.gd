class_name SelectableTeam
extends Node2D

signal team_selected(monster_team_selected: MonsterTeam)

@export var monster_team: MonsterTeam

@onready var monster_team_name_label: Label = $MonsterTeamNameLabel
@onready var select_team_button: DefaultButton = $SelectTeamButton

func _ready():
	monster_team_name_label.text = monster_team.get_monster_team_name_decorative()
	select_team_button.pressed.connect(_on_select_team_button_pressed)

func _on_select_team_button_pressed() -> void:
	emit_signal("team_selected", monster_team)
