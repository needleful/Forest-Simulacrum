extends Object

var _data: Dictionary

var commands_regex: RegEx

class Reply:
	var text:String
	var next:String
	var type:String
	var commands: Array = []

class Message:
	var pages: Array = []

class Page:
	var text : String
	var commands: Array = []
	
class Command:
	var command: String
	var args: PoolStringArray

func _init(source):
	commands_regex = RegEx.new()
	commands_regex.compile("\\[([^\\[\\]]+)\\]")
	var f = File.new()
	var res = f.open(source, File.READ)
	if res != OK:
		print_debug("Bad: Missing file "+ source)
		return res
	var json = f.get_as_text()
	_data = parse_json(json)
	
	if(typeof(_data) != TYPE_DICTIONARY):
		print_debug("Bad: Unexpected type of JSON")
		return ERR_PARSE_ERROR
		
func get_text(index) -> Message:
	var t:String = _data[index]['text']
	var lines = t.split("\n\n")
	var m = Message.new()
	for page_text in lines:
		var p:Page = Page.new()
		p.text = populate_commands(page_text, p.commands)
		m.pages.push_back(p)
	return m
	
func get_replies(index):
	var d = _data[index]
	var replies = []
	for val in d['replies']:
		var r:Reply = Reply.new()
		r.text = populate_commands(val['text'], r.commands)
		if val.has('id'):
			r.next = val['id']
		else:
			r.next = ""
		r.type = val['type']
		replies.push_back(r)
	return replies

func populate_commands(text:String, command_array: Array) -> String:
	var matches = commands_regex.search_all(text)
	for command in matches:
		var com = Command.new()
		var c:PoolStringArray = command.get_string(1).split(" ")
		com.command = c[0]
		c.remove(0)
		com.args = c
		command_array.push_back(com)
		text = text.replace(command.get_string(0), "")
	return text