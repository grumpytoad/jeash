package std.io;

import haxe.io.BytesData;

#if !js
#error
#end

class Bytes extends haxe.io.Bytes
{
	public function new (length, b) {
		super(length, b);
	}

	public static function alloc( length : Int ) : Bytes 
	{
		var bytes = haxe.io.Bytes.alloc(length);
		return new Bytes(bytes.length, bytes.getData() );
	}

	public static function ofData( b : BytesData ) 
	{
		var bytes = haxe.io.Bytes.ofData(b);
		return new Bytes(bytes.length, bytes.getData() );
	}

	public static function ofString( s : String ) : Bytes 
	{

		var a = [];
		for( i in 0...s.length ) {
			var c : Int = untyped s["cca"](i) & 0xFF;
			a.push(c);
		}

		return new Bytes(a.length,a);
	}

}
