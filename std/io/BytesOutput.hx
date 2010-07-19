package std.io;

import std.math.IEEE754;

class BytesOutput extends haxe.io.BytesOutput
{
	override public function writeString( s : String ) {
		var b = Bytes.ofString(s);
		writeFullBytes(b,0,b.length);
	}

	override public function writeDouble( x : Float ) {
		write( IEEE754.doubleToBytes( x, bigEndian ) );
	}

	override public function writeFloat( x : Float ) {
		write( IEEE754.floatToBytes( x, bigEndian ) );
	}
}
