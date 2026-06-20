extends Area2D

@export var damage_amount: int = 10
@export var damage_interval: float = 0.5

var damage_timer: Timer

func _ready() -> void:
	damage_timer = Timer.new()
	damage_timer.wait_time = damage_interval
	damage_timer.one_shot = false
	add_child(damage_timer)
	
	damage_timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		apply_damage(body)
		if damage_timer.is_stopped():
			damage_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var overlapping_players = get_overlapping_bodies().filter(func(b): return b.is_in_group("player"))
		if overlapping_players.is_empty():
			damage_timer.stop()

func _on_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			apply_damage(body)

func apply_damage(player: Node2D) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage_amount)
