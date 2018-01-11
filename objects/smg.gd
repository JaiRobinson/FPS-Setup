extends Spatial

var fireRate = 0.05

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func fire():
	randomize()
	
	var bullet = preload("res://objects/Bullet.tscn")
	var bulletInst = bullet.instance()
	#set the aim to be the z of the camers basis pluss a little random inaccuracy
	var aim = (get_node(".").get_global_transform().basis[2] + Vector3(rand_range(-0.1,0.1),rand_range(-0.1,0.1),rand_range(-0.1,0.1))).normalized()
	
	bulletInst.set_transform(get_parent().get_global_transform())
	bulletInst.set_linear_velocity(-(aim*80))
	get_tree().get_root().add_child(bulletInst)