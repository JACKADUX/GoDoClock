class_name CustomIterator

class Enumerate:
	var _array
	var index
	
	func _init(array:Array):
		_array = array

	func _iter_init(arg):
		index = 0
		return _array

	func _iter_next(arg):
		index += 1
		return index < _array.size()

	func _iter_get(arg):
		return {"index":index, "value":_array[index]}

class DirectoryIterator:
	var ori_directory :String
	var current :String
	var stack := []
	var current_dir:DirAccess
		
	func _init(directory:String):
		ori_directory = directory

	func _iter_init(arg):
		assert(ori_directory and DirAccess.dir_exists_absolute(ori_directory), 
				"not valid directory: '%s'"% ori_directory)
		current = ori_directory
		current_dir = DirAccess.open(ori_directory)
		current_dir.list_dir_begin()
		stack = []
		return true

	func _iter_next(arg):
		var file_name = current_dir.get_next()
		if file_name == "":
			while true:
				if not stack:
					return false
				current_dir.list_dir_end()
				current_dir = stack.pop_back()
				file_name = current_dir.get_next()
				if file_name:
					break
		current = current_dir.get_current_dir() +"/"+ file_name
		if current_dir.current_is_dir():
			stack.append(current_dir)
			current_dir = DirAccess.open(current)
			current_dir.list_dir_begin()

		return true

	func _iter_get(arg):
		return current


class TreeStructureIterator:
	var _current
	var ori
	
	func _init(current):
		_current = current
		ori = current

	func _iter_init(arg):
		_current = ori
		return _current

	func _iter_next(arg):
		var down = _current.get_first_child()
		if down:
			_current = down
			return true
		var next = _current.get_next()
		if next:
			_current = next
			return true
		while true:
			var parent = _current.get_parent()
			if not parent:
				return false
			next = parent.get_next()
			if next:
				_current = next
				return true
			_current = parent
		return false

	func _iter_get(arg):
		return _current
		
