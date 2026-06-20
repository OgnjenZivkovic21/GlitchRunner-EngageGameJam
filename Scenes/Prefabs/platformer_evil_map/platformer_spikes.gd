extends Area2D

@export var damage_amount: int = 10

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		apply_damage(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		apply_damage(body)

func apply_damage(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
