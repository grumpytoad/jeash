package jeash.display;

/**
* @author	Hugh Sanderson
* @author	Russell Weir
**/
class InteractiveObject extends DisplayObject
{
	public var doubleClickEnabled(__getDoubleClickEnabled,__setDoubleClickEnabled) : Bool;
	public var mouseEnabled:Bool;
	public var tabEnabled:Bool;
	public var tabIndex(default,SetTabIndex):Int;

	public function new()
	{
		super();
		tabEnabled = false;
		mouseEnabled = true;
		tabIndex = 0;
		name = "InteractiveObject";
	}

	override public function toString() { return name; }

	public function OnKey(inKey:flash.events.KeyboardEvent):Void { }

	override public function AsInteractiveObject() : flash.display.InteractiveObject
	{
		return this;
	}


	public function SetTabIndex(inIndex:Int)
	{
		tabIndex = inIndex;
		return inIndex;
	}

	/**
	* @todo Implement
	* @todo Check default right now, is it true or false?
	*/
	private function __getDoubleClickEnabled() : Bool {
		return true;
	}
	/**
	* @todo Implement
	*/
	private function __setDoubleClickEnabled(v:Bool) : Bool {
		return v;
	}

	public function OnFocusIn(inMouse:Bool) : Void { }
	public function OnFocusOut() : Void { }
	public function OnMouseDown(inX:Int, inY:Int) : Void { }
	public function OnMouseUp(inX:Int, inY:Int) : Void { }
	public function OnMouseDrag(inX:Int, inY:Int) : Void { }

}

