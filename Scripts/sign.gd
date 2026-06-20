extends Area2D

var player_in_range = false
@export var title: String = "Title"
@export_multiline var text: String = "Text"
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"): 
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		PlatformerInfo.open(title, text)
