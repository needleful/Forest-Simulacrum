extends Spatial

var funeral : Node
var tea_party : Node

onready var G = get_node("/root/global")
onready var anim: AnimationPlayer = $AnimationPlayer

var house_phase:int = 0
var house_parts:Array = []

func _ready():
	funeral = $funeral
	tea_party = $tea_party
	remove_child(funeral)
	remove_child(tea_party)
	$house/area.connect("body_entered", self, "on_house_entry")
	$house/area.connect("body_exited", self, "on_house_exit")
	$house/area.connect("area_entered", self, "on_house_entry")
	$house/area.connect("area_exited", self, "on_house_exit")
	G.connect("registered_event", self, "on_registered_event")
	G.ui = $ui
	G.inp = $ui/input_handler
	#Removing the house for building it later
	var house = $house_building
	for i in range(1,4):
		var phase = house.get_node("phase_"+str(i))
		print("got phase: ", str(i))
		house.remove_child(phase)
		house_parts.push_back(phase)
	#Disabling trees so they can be enabled
	get_tree().call_group("Tree_Small", "set_active", false)
	
func on_house_entry(body):
	print_debug("Entered house")
	$Music.stream_paused = true

func on_house_exit(body):
	print_debug("Exited house")
	$Music.stream_paused = false

func on_registered_event(name):
	if !has_method("event_"+name):
		print_debug("Unknown event: ", name)
	else:
		call("event_"+name)

func event_funeral(name = "Funeral"):
	G.remove_item("Flower", 4)
	anim.play("TeaTime_Fadeout")
	anim.queue("FuneralSunset")
	$Player/Anim.play("Screen_Fadeout")
	$Player/Anim.queue(name+"_Transport")
	$Player/Anim.queue("Screen_FadeIn")
	add_child(funeral)
	G.change_phase(G.HOUSE)
	#Disable taking flowers
	get_tree().call_group("Flower", "set_active", false)
	get_tree().call_group("Chamomile", "set_active", false)

func event_tea_party():
	G.remove_item("Chamomile")
	event_funeral("TeaParty")
	add_child(tea_party)

func event_get_saw():
	G.add_item("Saw")
	get_tree().call_group("SmallTree", "set_active", true)

func event_build_house():
	if house_phase+1 > house_parts.size():
		return
	var house = $house_building
	var phase:Node = house_parts[house_phase]
	if house_phase > 0:
		var old_phase = house.get_node("phase_"+str(house_phase))
		var rem = old_phase.get_node("to_remove")
		old_phase.remove_child(rem)
	house.add_child(phase)
	house_phase += 1
	if house_phase == 2:
		anim.play("Nightfall")
	elif house_phase == 3 && G.events.count("tea_party") > 0:
		anim.play("TeaParty_To_House")
		
