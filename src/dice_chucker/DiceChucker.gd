class_name DiceChucker
extends Node2D

signal value_shown

@onready var dice_sprite: Sprite2D = $DiceSprite
@onready var dice_roll_sprite: Sprite2D = $DiceRollSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	dice_roll_sprite.visible = false
	dice_sprite.frame = 19 # default to baseball

func chuck_dice(dice_val: int) -> void:
	dice_val = clampi(dice_val, 1, 20)
	animation_player.play("chuck")
	AudioManager.play_dice_roll()
	dice_sprite.frame = dice_val - 1
	await animation_player.animation_finished
	
	emit_signal("value_shown")

