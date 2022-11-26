extends RigidBody3D


func _ready():
	get_node("AnimationPlayer").play("LiftMotion")

	
#func _physics_process(delta):
#	move(Vector3(0,10,0))
