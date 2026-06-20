extends CharacterBody2D

var bullet_scene = preload("res://Scenes/Prefabs/shooter_alien_bullet.tscn")

@export var speed = 50
var player = null
var shootable: bool = false
var can_shoot: bool = true

var hp: int = 30

@onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if player:
		var direction_x = 1 if player.global_position.x > global_position.x else -1
		$AnimatedSprite2D.flip_h = (direction_x < 0)
		
		if shootable:
			velocity.x = 0
			shoot()
		else:
			velocity.x = direction_x * speed
	else:
		velocity.x = 0
	
	move_and_slide()

func shoot():
	if not can_shoot or not player: 
		return
	
	can_shoot = false
	
	$AudioStreamPlayer2D.play()
	
	var b = bullet_scene.instantiate()
	b.shooter = self
	get_parent().add_child(b)
	b.global_position = global_position
	
	var direction_x = 1 if player.global_position.x > global_position.x else -1
	
	if "direction" in b:
		b.direction = Vector2(direction_x, 0)
	if direction_x < 0:
		b.scale.x = -abs(b.scale.x) 
	else:
		b.scale.x = abs(b.scale.x)   
	
	await get_tree().create_timer(1.0).timeout
	can_shoot = true

func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player = body 

func _on_detection_area_body_exited(body):
	if body == player:
		player = null

func _on_shoot_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		shootable = true

func _on_shoot_range_body_exited(body: Node2D) -> void:
	if body == player:
		shootable = false

func die():
	queue_free()

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()
