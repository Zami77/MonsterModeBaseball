extends Node

var save_filename = "user://game_data.save"


var game_data = {}

func _ready():
	if OS.is_debug_build():
		save_filename = "res://game_data.save"

func save_game() -> void:
	var save_file = FileAccess.open(save_filename, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(game_data, '\t'))

func load_game() -> void:
	if not FileAccess.file_exists(save_filename):
		game_data = {
			'settings': {
				'fullscreen': false,
				'master_vol': 0.7,
				'music_vol': 0.45,
				'sfx_vol': 0.8
			},
			'persistent_data': {
				'tutorial_seen': false
			},
			'completed_matches': []
		}
		return
	
	var save_file = FileAccess.open(save_filename, FileAccess.READ)
	var save_file_text = save_file.get_as_text()
	
	if not save_file_text:
		return
	
	var save_data_json: Dictionary = JSON.parse_string(save_file_text)
	
	if not save_data_json:
		push_error("save_data was null")
		return
	
	game_data = save_data_json

func add_completed_match(completed_match):
	if not game_data.has('completed_matches'):
		game_data['completed_matches'] = []
	
	game_data.completed_matches.append(completed_match)
	
	save_game()
