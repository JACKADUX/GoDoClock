class_name BaseMessage

func _to_string():
	return "< BaseMessage#%d >"%get_instance_id()

class SimpleMessage extends BaseMessage:
	func _init(args:Array):
		var index = 0
		for arg in self.get_property_list():
			if (arg.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != PROPERTY_USAGE_SCRIPT_VARIABLE:
				continue
			self.set(arg.name, args[index])
			index += 1
			
		if index < args.size():
			push_warning("not all args being used! %d/%d"%[index, args.size()])
	
	func _to_string():
		return "< SimpleMessage#%d >"%get_instance_id()
