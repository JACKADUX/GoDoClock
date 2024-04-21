class_name HierarchyData extends Resource

@export var _parent:HierarchyData=null
@export var _children:Array = []

enum DragDrop {
	BEFORE=-1,
	UNDER=0,
	AFTER=1,
}

#region Hierarchy
func is_ancestor_of(data:HierarchyData) -> bool:
	for child in iterate():
		if child == data:
			return true
	return false

func get_parent() -> HierarchyData:
	return _parent

func add_child(child: HierarchyData) -> Error:
	if child in _children:
		return FAILED
	if child.get_parent():
		return FAILED
	if child.is_ancestor_of(self):
		return FAILED
	_children.append(child)
	child._parent = self
	return OK
	
func remove_child(child: HierarchyData) -> Error:
	if child not in _children:
		return FAILED
	_children.erase(child)
	child._parent = null
	return OK

func get_index() -> int:
	if not _parent:
		return -1
	return _parent._children.find(self)

func get_children() -> Array:
	return _children.duplicate()

func get_child_count() -> int:
	return _children.size()

func get_child(index:int):
	return _children[index]

func move_child(child: HierarchyData, to_index: int) -> Error:
	if child not in _children:
		return FAILED
	var current_index = _children.find(child)
	if current_index == -1 or current_index == to_index:
		return FAILED
	_children.erase(child)
	to_index = clamp(to_index, 0, _children.size())
	if to_index >= _children.size():
		_children.append(child)
	else:
		_children.insert(to_index, child)
	return OK

func move_before(other:HierarchyData) -> Error:
	if other == self:
		return FAILED
	var other_parent := other.get_parent()
	assert(other_parent, "other_parent 必须存在才能用这个方法")
	if not _parent:
		other_parent.add_child(self)
	elif _parent != other_parent:
		_parent.remove_child(self)
		other_parent.add_child(self)
	if get_index() != other.get_index():
		other_parent.move_child(self, other.get_index())
	return OK
	
func move_after(other:HierarchyData) -> Error:
	if other == self:
		return FAILED
	var other_parent := other.get_parent()
	assert(other_parent, "other_parent 必须存在才能用这个方法")
	if not _parent:
		other_parent.add_child(self)
	elif _parent != other_parent:
		_parent.remove_child(self)
		other_parent.add_child(self)
	var other_index = other.get_index()
	if get_index() < other_index:
		other_parent.move_child(self, other.get_index())
	else:
		other_parent.move_child(self, other.get_index()+1)
	return OK
		
func drag_to(drop:HierarchyData, section:DragDrop) -> Error:
	if drop == self:
		return FAILED
	match section:
		DragDrop.BEFORE:
			return move_before(drop)
		DragDrop.UNDER: 
			if get_parent():
				get_parent().remove_child(self)
			drop.add_child(self)
			return OK
		DragDrop.AFTER:
			return move_after(drop)
	return FAILED 
	
func iterate():
	return Iterator.new(self)

#endregion
class Iterator:
	var _current:HierarchyData
	var ori:HierarchyData
	
	func _init(current):
		_current = current
		ori = current

	func _iter_init(arg):
		_current = ori
		return _current
	
	func get_next(obj:HierarchyData):
		var parent = obj.get_parent()
		if not parent:
			return 
		var count = parent.get_child_count()
		var index = obj.get_index()+1 
		if index < count:
			return parent.get_child(index)
	
	func _iter_next(arg):
		if _current.get_child_count() >0:
			_current = _current.get_child(0)
			return true
		var next = get_next(_current)
		if next:
			_current = next
			return true
		while true:
			var parent = _current.get_parent()
			if not parent:
				return false
			next = get_next(parent)
			if next:
				_current = next
				return true
			_current = parent
		return false

	func _iter_get(arg):
		return _current
		
static func print_tree(element:HierarchyData, level:int=0):
	print("\t".repeat(level), element)
	for child in element.get_children():
		print_tree(child, level+1)
