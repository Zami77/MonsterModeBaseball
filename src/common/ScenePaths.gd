class_name ScenePaths
extends Node

static var main_menu = "res://src/ui/main_menu/MainMenu.tscn"
static var credits_screen = "res://src/ui/credits_screen/CreditsScreen.tscn"
static var settings_menu = "res://src/ui/settings_menu/SettingsMenu.tscn"
static var match_manager = "res://src/managers/match_manager/MatchManager.tscn"
static var team_select = "res://src/ui/team_select_screen/TeamSelectScreen.tscn"

static var slaks_slugger_packed_scene = preload("res://src/monster_cards/goblins/slaks_slugger/SlaksSlugger.tscn")
static var glurm_packed_scene = preload("res://src/monster_cards/goblins/glurm/Glurm.tscn")

static var batter_plus_one_pitcher_minus_one_packed_scene = preload("res://src/special_cards/batter_plus_one_pitcher_minus_one/BatterPlusOnePitcherMinusOne.tscn")
static var batter_plus_two_packed_scene = preload("res://src/special_cards/batter_plus_two/BatterPlusTwo.tscn")
static var pitcher_plus_one_batter_minus_one_packed_scene = preload("res://src/special_cards/pitcher_plus_one_batter_minus_one/PitcherPlusOneBatterMinusOne.tscn")
static var pitcher_plus_two_packed_scene = preload("res://src/special_cards/pitcher_plus_two/PitcherPlusTwo.tscn")

static var goblin_team_resource = preload("res://src/teams/goblin_team/GoblinTeam.tres")
