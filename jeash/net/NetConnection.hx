package jeash.net;

import jeash.events.EventDispatcher;

class NetConnection extends EventDispatcher
{
	public var connect:Dynamic;
	
	public function new() : Void
	{
		super();
		connect = Reflect.makeVarArgs(js_connect);
		//should set up bidirection connection with Flash Media Server or Flash Remoting
		//currently does nothing
	}

	private function js_connect (val:Array<Dynamic>) : Void
	{
		if (val.length > 1 || val[0] != null)
		throw "jeash can only connect in 'http streaming' mode";
		
		//dispatch events:
		//connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		//connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	}

}