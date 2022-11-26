extends Node3D

var fireRate = 0.25

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func fire():
	
	var bullet = preload("res://objects/Bullet_sphere.tscn")
	var bulletInst = bullet.instantiate()
	bulletInst.set_transform(get_parent().get_global_transform())
	bulletInst.set_linear_velocity(-((get_node(".").get_global_transform().basis[2].normalized()*20)))
	get_tree().get_root().add_child(bulletInst)
	
	
	print("BANG!")