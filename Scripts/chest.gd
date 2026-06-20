extends Area2D
class_name Chest

# Spremamo mesta za loot predmete koje možeš da prevučeš iz FileSystem-a u Inspector
@export var loot_item_1: PackedScene # Npr. Novčić (Čest)
@export var loot_item_2: PackedScene # Npr. Srce za HP (Srednje čest)
@export var loot_item_3: PackedScene # Npr. Moćno oružje/ključ (Redak)

@export var loot: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var loot_spawn_point: Marker2D = $LootSpawnPoint

var player_inside: Node2D = null
var is_opened: bool = false

func _ready() -> void:
	# Povezivanje signala za detekciju igrača
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Postavi škrinju na početni frejm zatvorene animacije
	animated_sprite.play("idle")


func _unhandled_input(event: InputEvent) -> void:
	# Ako je igrač pored zatvorene škrinje i pritisne strelicu na dole
	if player_inside and not is_opened and event.is_action_pressed("ui_down"):
		open_chest()


func open_chest() -> void:
	print("Škrinja se otvara!")
	is_opened = true
	
	# 1. Pusti animaciju otvaranja
	animated_sprite.play("open")
	
	# 2. Pozovi funkciju koja stvara random loot
	spawn_loot()


func spawn_loot() -> void:
	# Biramo nasumičan broj od 0 do 100 za verovatnoću
	var random_roll = randf_range(0.0, 100.0)
	var selected_loot: PackedScene = null
	
	# Sistem šansi:
	if loot == 1:
		selected_loot = loot_item_1
	elif loot == 2:
		selected_loot = loot_item_2
	elif loot == 3:
		selected_loot = loot_item_3
		
	if selected_loot == null:
		return
		
	var item_instance = selected_loot.instantiate() as Node2D
	get_tree().current_scene.add_child(item_instance)
	
	item_instance.global_position = loot_spawn_point.global_position
	
	if "velocity" in item_instance:
		item_instance.velocity = Vector2(randf_range(-100, 100), -250)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = body
		print("Igrač je prišao škrinji.")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = null
		print("Igrač se udaljio od škrinje.")
