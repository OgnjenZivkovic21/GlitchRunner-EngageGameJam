extends Weapon

@onready var attack_sprite = $attack
@onready var muzzle = $muzzle

var bullet_scene = preload('res://Scenes/Prefabs/platformer_weapons/platformer_dungara_bullet.tscn')

@onready var player = $csPlayer

@onready var original_muzzle_x = muzzle.position.x


func flip_weapon(is_left: bool):
	attack_sprite.flip_h = is_left
	if is_left:
		muzzle.position.x = -abs(original_muzzle_x)
	else:
		muzzle.position.x = abs(original_muzzle_x)

func attack():
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.global_position = muzzle.global_position
	b.shooter = self # Bitno da metak ne ubije igrača odmah
	
	# Ovde određujemo smer!
	var shoot_direction = -1 if attack_sprite.flip_h else 1
	b.direction = Vector2(shoot_direction, 0)
	player.play()
 
