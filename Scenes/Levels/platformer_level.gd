extends Node2D

@onready var platformer_health_bar: ProgressBar = $CanvasLayer/PlatformerHealthBar

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass


func _on_character_body_2d_health_changed(new_health: Variant) -> void:
	platformer_health_bar.update(new_health)


func _on_alien_shooter_2_tree_exited() -> void:
	# da se pojavi sifra na vratima kad crknre
	pass
