extends Node
class_name FileUtils


static func save_json(
	data,
	file_name
):
	var file = FileAccess.open(
		"res://" + file_name,
		FileAccess.WRITE
	)
	var json_string = JSON.stringify(data)
	print(json_string)
	file.store_string(json_string)
	
static func save_json_list(
	data,
	file_name
):
	var file = FileAccess.open(
		"res://" + file_name,
		FileAccess.WRITE
	)
	for line in data:
		var json_string = JSON.stringify(line)
		print(json_string)
		file.store_string(json_string)
	
static func load_json(file_name):
	if not FileAccess.file_exists("res://" + file_name):
		return null
	
	var save_file = FileAccess.open("res://" + file_name, FileAccess.READ)
	
	#var json_string = save_file.get_line()
	var json = JSON.new()
	
	var parse_result = json.parse_string(save_file.get_line())
	return parse_result


static func load_json_list(file_name):
	if not FileAccess.file_exists("res://" + file_name):
		return null
	
	var save_file = FileAccess.open("res://" + file_name, FileAccess.READ)
	
	var text = save_file.get_as_text()
	
	
	#var json_string = save_file.get_line()
	var json = JSON.new()
	var data = []
	while not save_file.eof_reached():
		var line = save_file.get_line()
		if line == null:
			continue
		var parse_result = json.parse_string(line)
		data.append(parse_result)
	return data
