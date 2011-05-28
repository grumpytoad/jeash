package jeash.errors;

import haxe.Stack;

class Error
{
	public var errorID:Int;
	public var message:String;
	public var name:String;

	static inline var DEFAULT_TO_STRING = "Error";

	public function new (message:String = "", id:Int = 0) {
		this.message = message;
		this.errorID = id;
	}

	public function getStackTrace() {
		return Stack.toString(Stack.exceptionStack());
	}

	public function toString() {
		if (message != null)
			return message;
		else
			return DEFAULT_TO_STRING;
	}
}
