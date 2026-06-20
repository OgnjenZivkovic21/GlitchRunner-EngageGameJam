extends CharacterBody2D

@export var max_hp: int = 100
var current_hp: int = max_hp
var current_weapon: Weapon = null

var lightsaber_scene = preload("res://Scenes/Prefabs/platformer_weapons/platformer_lightsaber.tscn")
var rifle_scene = preload("res://Scenes/Prefabs/platformer_weapons/platformer_dungara.tscn")

var original_x = 0

var SPEED = 200.0
var JUMP_VELOCITY = -300.0

signal health_changed(new_health)

func _ready():
	add_to_group("player")
	current_hp = max_hp
	
	var w = lightsaber_scene.instantiate()
	$WeaponSlot.add_child(w)
	current_weapon = w
	
	original_x = $WeaponSlot.position.x

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if current_weapon:
			current_weapon.attack()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("run")
		if direction > 0:
			$AnimatedSprite2D.flip_h = false
			$WeaponSlot.position.x = abs(original_x)
			if $WeaponSlot.get_child_count() > 0:
				$WeaponSlot.get_child(0).flip_weapon(false)
		elif direction < 0:
			$AnimatedSprite2D.flip_h = true
			$WeaponSlot.position.x = original_x - 40
			if $WeaponSlot.get_child_count() > 0:
				$WeaponSlot.get_child(0).flip_weapon(true)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1
	move_and_slide()

func take_damage(amount: int):
	current_hp -= amount
	if current_hp < 0: current_hp = 0
	health_changed.emit(float(current_hp * 1.0 / max_hp) * 100.0)
	if current_hp <= 0:
		die()

func die():
	get_tree().reload_current_scene()

func equip_weapon(weapon_name: String) -> void:
	if weapon_name == "platformer_dungara":
		if current_weapon:
			current_weapon.queue_free()
			
		var new_rifle = rifle_scene.instantiate()
		$WeaponSlot.add_child(new_rifle)
		current_weapon = new_rifle
		
		if $AnimatedSprite2D.flip_h:
			new_rifle.flip_weapon(true)
		else:
			new_rifle.flip_weapon(false)

func apply_power_boost(speed_multiplier: float, jump_multiplier: float, duration: float) -> void:
	SPEED = 200.0 * speed_multiplier
	JUMP_VELOCITY = -300.0 * jump_multiplier
	self.modulate = Color(1.5, 1.5, 0.5)
	
	await get_tree().create_timer(duration).timeout
	
	SPEED = 200.0
	JUMP_VELOCITY = -300.0
	self.modulate = Color(1, 1, 1)
