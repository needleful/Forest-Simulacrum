extends GraphEdit

onready var editor = 

func _ready():
	connect("connection_request", self, "on_connection_request)