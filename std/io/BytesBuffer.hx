package std.io;

class BytesBuffer extends haxe.io.BytesBuffer
{
	public function getBytes_() : Bytes {
		var bytes = new Bytes(b.length,b);
		b = null;
		return bytes;
	}
}

