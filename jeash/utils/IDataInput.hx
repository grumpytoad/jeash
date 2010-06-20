package jeash.utils;


import haxe.io.Input;


class IDataInput
{
   var mInput:Input;
   // not implemented ...
   //var bytesAvailable(default,null) : UInt;
   //var endian : String;
   //var objectEncoding : UInt;

   public function new(inInput:Input)
   {
      mInput = inInput;
   }
   public function close() : Void { mInput.close(); }

   public function readAll( ?bufsize : Int ) : haxe.io.Bytes
      { return mInput.readAll(bufsize); }

   public function readBoolean() : Bool { return mInput.readInt8()!=0; }
   public function readByte() : Int { return mInput.readByte(); }
   public function readBytes(inLen : Int) { return mInput.read(inLen); }
   public function readDouble() : Float { return mInput.readDouble(); }
   public function readFloat() : Float { return mInput.readFloat(); }
   public function readInt() : Int { return haxe.Int32.toInt(mInput.readInt32()); }
   public function readUnsignedInt() : Int { return haxe.Int32.toInt(mInput.readInt32()); }
   public function readShort() : Int { return mInput.readInt16(); }
   public function readUTFBytes(length : Int) : haxe.io.Bytes { return mInput.read(length); }
   public function readUnsignedByte() : Int { return mInput.readByte(); }
   public function readUnsignedShort() : Int { return mInput.readUInt16(); }
}



