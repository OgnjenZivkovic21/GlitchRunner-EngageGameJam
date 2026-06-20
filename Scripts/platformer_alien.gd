extends CharacterBody2D
class_name platformer_alien

var hp: int = 50
var speed: int = 200
var damage: int = 10
var vidokrug_x: int = 250
var vidokrug_y: int = 40
var atk_speed = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: Node2D = null
var player_in_range = null

var damage_timer: Timer
var attack_sound: AudioStreamPlayer2D

func _ready():
	add_to_group("enemy")
	attack_sound = AudioStreamPlayer2D.new()
	
	var sound_file = load("res://Assets/platform_sounds/hus.ogg")
	if sound_file:
		attack_sound.stream = sound_file
	
	add_child(attack_sound)
	damage_timer = Timer.new()
	damage_timer.wait_time = atk_speed
	damage_timer.one_shot = false
	
	damage_timer.timeout.connect(_on_timer_timeout)
	add_child(damage_timer)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if player_in_range:
		velocity.x = 0
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0
	elif player:
		var direction = sign(player.global_position.x - global_position.x)
		if abs(player.global_position.x - global_position.x) > vidokrug_x or abs(player.global_position.y - global_position.y) > vidokrug_y:
			direction = 0
		
		velocity.x = direction * speed
		
		if direction != 0:
			if not $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play("default")
			$AnimatedSprite2D.flip_h = (direction < 0)
		else:
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.frame = 0
	else:
		velocity.x = 0
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0

	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = body
		deal_demage()
		damage_timer.start() 

func _on_hitbox_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		damage_timer.stop() 

func _on_timer_timeout():
	deal_demage()

func take_damage(amount: int):
	hp -= amount
	print(name, " primio štetu! Preostalo HP: ", hp)
	if hp <= 0:
		die()

func deal_demage():
	if attack_sound: attack_sound.play()
	if player_in_range and player_in_range.has_method("take_damage"):
			player_in_range.take_damage(damage)

func die():
	queue_free()	
