# This is a class that contains wrappers for calling 
# into dialog data from a JSON file.  It's specifically
# for DialogViewer, as DialogEditor reads the JSON
# and does its own thing with it.
# You'd think having one data class that both communicate
# to would be more efficient, but in the immediate future
# this separation was far more efficient.
extends Object
class_name DialogTree

var _data: Dictionary

var commands_regex: RegEx
var queries_regex:RegEx

class Reply:
	var text:String
	var next:String
	var type:String
	var conditions: Array = []
	var commands: Array = []

class Message:
	var pages: Array = []

class Page:
	var text : String
	var commands: Array = []
	var conditions: Array = []
	
class Command:
	var command: String
	var args: PoolStringArray

func _init(source):
	commands_regex = RegEx.new()
	queries_regex = RegEx.new()
	# Matches commands, which are strings of text between square brackets
	commands_regex.compile("\\[([^\\[\\]]+)\\]")
	#Queries are the same but with a ? at the front
	queries_regex.compile("\\?\\[([^\\[\\]]+)\\]")
	var f = File.new()
	var res = f.open(source, File.READ)
	if res != OK:
		print_debug("Bad!! Missing file: ", source)
		return res
	var json = f.get_as_text()
	_data = parse_json(json)
	
	if(typeof(_data) != TYPE_DICTIONARY):
		print_debug("Bad!! Unexpected type of JSON: ", typeof(_data))
		return ERR_PARSE_ERROR

func get_text(index) -> Message:
	var t:String = _data[index]['text']
	var lines = t.split("\n\n")
	var m = Message.new()
	for page_text in lines:
		var p:Page = Page.new()
		p.text = populate_commands(queries_regex, page_text, p.conditions)
		p.text = populate_commands(commands_regex, p.text, p.commands)
		m.pages.push_back(p)
	return m

func get_replies(index) -> Array:
	var d = _data[index]
	var replies = []
	for val in d['replies']:
		var r:Reply = Reply.new()
		r.text = populate_commands(queries_regex, val['text'], r.conditions)
		r.text = populate_commands(commands_regex, r.text, r.commands)
		if val.has('id') && val['id'] != null:
			r.next = val['id']
		else:
			r.next = ""
		r.type = val['type']
		replies.push_back(r)
	return replies

# Search for commands in a string of text
# (using provided regex for various command types)
func populate_commands(regex:RegEx, text:String, command_array: Array) -> String:
	var matches = regex.search_all(text)
	for command in matches:
		var com = Command.new()
		var c:PoolStringArray = command.get_string(1).split(" ")
		# Fun fact: arrays of strings are not of type Array,
		# and as a result they don't have the pop_front method
		com.command = c[0]
		c.remove(0)
		com.args = c
		command_array.push_back(com)
		text = text.replace(command.get_string(0), "")
	return text