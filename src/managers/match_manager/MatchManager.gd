class_name MatchManager
extends Node2D

@export var total_innings = 3
@export var outs_per_inning = 3

@onready var bases_manager: BasesManager = $BasesManager

var current_inning: Dictionary = {
	'inning': 1,
	'inning_frame': InningFrame.TOP
}
var home_team
var away_team

enum InningFrame { TOP, BOTTOM }



