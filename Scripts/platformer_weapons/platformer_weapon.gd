# Weapon.gd
extends Node2D
class_name Weapon

@export var damage: int = 10

# Ova funkcija će se razlikovati za svaki weapon (override)
func attack():
	print("Ovo treba da implementira konkretan weapon")
