extends Node

var rng = RandomNumberGenerator.new()

var dice_bag: Array[int] = []
var dice_bag_size = 2

func _ready():
	rng.randomize()
	_fill_bags()

func roll_die() -> int:
	if not dice_bag:
		_fill_bags()
	
	return dice_bag.pop_at(rng.randi_range(0, len(dice_bag) - 1))

func _fill_bags() -> void:
	dice_bag = []
	
	for bag in dice_bag_size:
		for i in range(1, 21):
			dice_bag.append(i)
