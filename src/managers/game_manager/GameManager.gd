class_name GameManager
extends Node2D

@export_file("*.tscn", "*.scn") var default_scene = "res://src/ui/main_menu/MainMenu.tscn"

@onready var transition_screen: TransitionScreen = $TransitionScreen
@onready var camera: CameraManager = $CameraManager

var current_scene = null
var selected_monster_team_name: MonsterTeam.TeamName = MonsterTeam.TeamName.GOBLIN_TEAM
var rng = RandomNumberGenerator.new()

func _ready():
	DataManager.load_game()
	SettingsManager.load_settings()
	transition_screen.visible = false
	_load_scene(default_scene)
	rng.randomize()

func _load_scene(scene_path: String) -> void:
	DataManager.save_game()
	transition_screen.fade_to_black()
	await transition_screen.faded_to_black
	
	var new_packed_scene = load(scene_path) as PackedScene
	var new_scene = new_packed_scene.instantiate()
	
	if current_scene:
		current_scene.queue_free()
	
	current_scene = new_scene
	transition_screen.fade_to_scene()
	add_child(new_scene)
	
	if current_scene is MainMenu:
		current_scene.option_selected.connect(_on_main_menu_option_selected)
	
	if current_scene is CreditsScreen:
		current_scene.back_to_main_menu.connect(_on_back_to_main_menu)
	
	if current_scene is InstructionsScreen:
		current_scene.back_to_main_menu.connect(_on_back_to_main_menu)
		
	if current_scene is SettingsMenu:
		current_scene.back_to_main_menu.connect(_on_back_to_main_menu)
	
	if current_scene is TeamSelectScreen:
		current_scene.team_selected.connect(_on_team_selected)
	
	if current_scene is MatchManager:
		current_scene.setup(
			MonsterTeamFactory.get_monster_team(selected_monster_team_name), 
			MonsterTeamFactory.get_monster_team(_get_away_team())
		)
		current_scene.back_to_main_menu.connect(_on_back_to_main_menu)
		current_scene.camera_shake.connect(_on_camera_shake)
	
	await transition_screen.faded_to_scene

func _on_camera_shake(trauma: float) -> void:
	camera.add_trauma(trauma)

func _on_back_to_main_menu() -> void:
	_load_scene(ScenePaths.main_menu)

func _on_team_selected(team_name: MonsterTeam.TeamName) -> void:
	selected_monster_team_name = team_name
	_load_scene(ScenePaths.match_manager)

func _on_main_menu_option_selected(option: MainMenu.Option) -> void:
	match option:
		MainMenu.Option.PLAY_GAME:
			_load_scene(ScenePaths.team_select)
		MainMenu.Option.SETTINGS:
			_load_scene(ScenePaths.settings_menu)
		MainMenu.Option.INSTRUCTIONS:
			_load_scene(ScenePaths.instructions_screen)
		MainMenu.Option.CREDITS:
			_load_scene(ScenePaths.credits_screen)
		MainMenu.Option.EXIT_GAME:
			get_tree().quit()

func _get_away_team() -> MonsterTeam.TeamName:
	var all_teams = MonsterTeamFactory.all_monster_teams.duplicate()
	all_teams.erase(selected_monster_team_name)
	
	return all_teams.pop_at(rng.randi_range(0, len(all_teams) - 1))
