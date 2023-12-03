class_name DiceChucker
extends Node2D

signal value_shown

@onready var dice_sprite: Sprite2D = $DiceSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func chuck_dice(dice_val: int) -> void:
	animation_player.play("chuck")
	await animation_player.animation_finished
	
	dice_sprite.frame = dice_val - 1
	emit_signal("value_shown")
