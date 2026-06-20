extends Area2D
class_name HealthPotion

@export var heal_amount: int = 20

func _ready() -> void:
	# Povezujemo signal – čim neko (igrač) uđe u našu zonu, okida se funkcija
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Proveravamo da li je telo koje nas je dotaklo igrač
	if body.is_in_group("player") or body.is_in_group("Player"):
		print("Igrač je pokupio Health Potion!")
		
		# Provera da li tvoj igrač ima funkciju za lečenje (npr. heal() ili add_hp())
		if body.has_method("heal"):
			body.heal(heal_amount)
		elif "hp" in body:
			# Ako nemaš funkciju nego direktno menjaš varijablu (pazi na maksimalni HP!)
			body.hp = min(body.hp + heal_amount, 100) 
			print("Igraču vraćeno ", heal_amount, " HP. Trenutni HP: ", body.hp)
		
		# Opciono: Ovde možeš pustiti zvuk sakupljanja pre nego što uništiš objekat
		
		# Napitak nestaje sa mape jer je iskorišćen
		queue_free()
