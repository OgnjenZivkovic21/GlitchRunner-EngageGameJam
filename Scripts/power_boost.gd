extends Area2D
class_name PowerBoostLoot

@export var speed_boost: float = 1.5  # Povećava brzinu za 50% (200 -> 300)
@export var jump_boost: float = 1.3   # Povećava skok za 30% (-300 -> -390)
@export var boost_duration: float = 7.0 # Trajanje u sekundama

func _ready() -> void:
	# Povezujemo ugrađeni signal za detekciju
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player"):
		print("Igrač je pokupio Power Boost!")
		
		# Pozivamo funkciju koju smo upravo dodali igraču
		if body.has_method("apply_power_boost"):
			body.apply_power_boost(speed_boost, jump_boost, boost_duration)
			
		# Brišemo predmet sa zemlje
		queue_free()
