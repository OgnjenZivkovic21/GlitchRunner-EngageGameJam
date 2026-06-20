extends Area2D
class_name Door
@export var door_id: String = "0000"
@export var is_exit_door: bool = false # Označi sa TRUE ako ova vrata završavaju nivo
const KEYPAD_SCENE = preload("res://Scenes/Prefabs/keypad.tscn")
@export var platformer_alien_basic: PackedScene = preload("res://Scenes/Prefabs/platformer_alien_basic.tscn")
@export var platformer_alien_fast: PackedScene = preload("res://Scenes/Prefabs/platformer_alien_fast.tscn")
@export var platformer_alien_tank: PackedScene = preload("res://Scenes/Prefabs/platformer_alien_tank.tscn")
@export var alien_shooter: PackedScene = preload("res://Scenes/Prefabs/platformer_alien_shooter.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Proveri da li ti se čvor tačno ovako zove!

var is_spawning_monsters: bool = false # Prati da li vrata trenutno izbacuju čudovišta

const TRAP_CODES = ["0136", "0170", "0119","0187"]
var is_unlocked: bool = false
var player_inside: Node2D = null

@onready var code_label: Label = $Label

func _ready() -> void:
	# Na početku, tekst iznad vrata je uvek skriven iza zvezdica
	if code_label:
		code_label.text = "****"
	if door_id == "0000":
		code_label.text = "0000"
		is_unlocked = true
	elif door_id == "1111":
		code_label.text = "1111"
		is_unlocked = true
	# Povezivanje signala za detekciju igrača
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	# Uslov: Igrač je pored vrata i pritisnuo je taster za interakciju (npr. slovo E ili Enter)
	# Napomena: "ui_accept" je po defaultu Space/Enter, ti posle možeš napraviti svoj action za "interact"
	if player_inside and event.is_action_pressed("ui_down"):
		open_input_menu()


# =====================================================================
# MESTO ZA TVOJ KOD (ZADATAK 1)
# =====================================================================
func open_input_menu() -> void:
	print("Otvaram keypad...")
	
	# Stvaramo keypad na ekranu
	var keypad_instance = KEYPAD_SCENE.instantiate() as Keypad
	get_tree().current_scene.add_child(keypad_instance)
	
	# Ključni deo: Slušamo kada keypad pošalje signal 'code_submitted'
	# Kada igrač klikne OK, automatski se poziva naša funkcija try_teleport sa tim kodom
	keypad_instance.code_submitted.connect(try_teleport)


# =====================================================================
# LOGIKA ZA TELEPORTACIJU I OTKLJUČAVANJE
# =====================================================================
#func try_teleport(entered_code: String) -> void:
	## Tražimo sva vrata koja postoje na mapi (moraju biti u grupi "doors")
	#var all_doors = get_tree().get_nodes_in_group("doors")
	#var target_door: Door = null
	#
	## Prolazimo kroz sva vrata i tražimo poklapanje ID-ja
func try_teleport(entered_code: String) -> void:
	# 1. PROVERA: Da li je ukucana šifra-zamka?
	if entered_code in TRAP_CODES:
		trigger_monster_trap(entered_code)
		return # Prekidamo funkciju ovde, nema teleportacije!
		
	# 2. Ako nije zamka, nastavlja se normalna pretraga vrata (tvoj postojeći kod)
	var all_doors = get_tree().get_nodes_in_group("doors")
	var target_door: Door = null
	
	for door in all_doors:
		if door is Door and door.door_id == entered_code:
			target_door = door
			break
			
	if target_door:
		print("Šifra tačna! Teleportacija na vrata: ", entered_code)
		if player_inside:
			player_inside.global_position = target_door.global_position
			target_door.unlock_door()
	else:
		print("Pogrešna šifra! Ni jedna vrata nemaju ID: ", entered_code)

func trigger_monster_trap(code: String) -> void:
	print("ALARM! Ukucana je šifra zamke: ", code)
	
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "UPOZORENJE!"
	error_dialog.dialog_text = "Pogrešna šifra! Aktivirali ste odbrambeni sistem!\nČudovišta dolaze..."
	get_tree().current_scene.add_child(error_dialog)
	
	error_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	error_dialog.popup_centered()
	
	# Kada igrač klikne OK, pokreće se sekvenca sa kašnjenjem
	error_dialog.confirmed.connect(func():
		error_dialog.queue_free() # Brišemo prozor sa ekrana, igra se odpauzira
		
		# Dodajemo dramatičnu pauzu od 2 sekunde dok igra normalno teče
		print("Čudovišta stižu za 2 sekunde... Pripremi se!")
		
		
		# Tek nakon što prođu 2 sekunde, pozivamo stvaranje čudovišta
		spawn_monsters(4)
	)# TODO: Ovde ćemo u sledećem koraku dodati kod za stvaranje (spawn) 3-4 čudovišta

func spawn_monsters(amount: int) -> void:
	print("Pokrećem sekvencijalno stvaranje čudovišta na centru vrata...")
	
	# 1. Zaključavamo vrata u otvorenom stanju i palimo animaciju (za svaki slučaj)
	is_spawning_monsters = true
	await get_tree().create_timer(2.0).timeout
	#animated_sprite.play("open")
	
	var spawn_offsets = [-80, -40, 40, 80] 
	
	for i in range(amount):
		var random_roll = randf_range(0.0, 100.0)
		var selected_scene: PackedScene = null
		
		if random_roll <= 40.0:
			selected_scene = platformer_alien_basic
		elif random_roll <= 65.0:
			selected_scene = platformer_alien_fast
		elif random_roll <= 85.0:
			selected_scene = alien_shooter
		else:
			selected_scene = platformer_alien_tank
		
		if selected_scene == null:
			continue
			
		var monster_instance = selected_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(monster_instance)
		monster_instance.global_position = global_position + Vector2(0, -20)
		
		print("Čudovište ", i + 1, " stvoreno!")
		
		if i < amount - 1:
			await get_tree().create_timer(1.0).timeout
			
	print("Sva čudovišta su izašla!")
	
	# 2. Završeno stvaranje: skidamo blokadu sa vrata
	is_spawning_monsters = false
	
	# 3. Logika zatvaranja: Ako je igrač već pobegao (player_inside je null), zatvori vrata unazad
	if player_inside == null:
		print("Igrač nije blizu, zatvaram vrata nakon zamke.")
		animated_sprite.play_backwards("open")
	else:
		print("Igrač je i dalje blizu vrata, ostaju otvorena.")
		
func unlock_door() -> void:
	is_unlocked = true
	if code_label:
		code_label.text = door_id
	print("Vrata ", door_id, " su otključana i njihov ID je sada vidljiv.")


# =====================================================================
# DETEKCIJA PROSTORA (SIGNALI)
# =====================================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = body
		print("Igrač je prišao vratima.")
		
		# Ako se čudovišta već ne stvaraju, otvori vrata normalno
		if not is_spawning_monsters:
			animated_sprite.play("open") # Zamenite "open" nazivom vaše animacije otvaranja


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = null
		print("Igrač je otišao od vrata.")
		
		# Vrata se zatvaraju SAMO ako je igrač otišao I ako se trenutno ne stvaraju čudovišta
		if not is_spawning_monsters:
			animated_sprite.play_backwards("open")
