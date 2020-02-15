extends Node

class Either:
	var left
	var right

static func dir_contents(path: String) -> Array:
	var retval: Either
	
	var arr: Array = []
	
	var dir := Directory.new()
	if dir.open(path) != OK:
		return arr
	else:
		dir.list_dir_begin()
		var fname := dir.get_next()
		while not fname.empty():
			if not dir.current_is_dir():
				arr.append(fname)
			fname = dir.get_next()
	return arr

# Get scenes from path that belong to group
func get_scenes(path: String, group: String) -> Array:
	var retval: Array = []
	
	var conts := dir_contents(path)
	
	for c in conts:
		var node = load(path + c).instance()
		if node.is_in_group(group):
			retval.append(node)
		else:
			node.queue_free()
	
	return retval
