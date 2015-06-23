package com.guagua.chat.util
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class RC6
	{
		private static var l_key:Vector.<uint>=new Vector.<uint>(44);
		private static var instance:RC6 = null;
		
		public function RC6()
		{
			
		}
		
		static public function getInstance():RC6{
			if(instance == null){
				instance = new RC6();
			}			
			return instance;
		}
		
		private function rotr(x:uint,n:uint):uint {
			return ((x >>> n)) | (x << (32 - n));
		}
		
		private function rotl(x:uint,n:uint):uint{
			return (x << n) | (x >>> (32 - n));
		}
		
		private function f_rnd(i:int,a:uint,b:uint,c:uint,d:uint):Vector.<uint>{
			var retArr:Vector.<uint> = new Vector.<uint>(2);
			var u_temp1:uint = (d + d + 1);
			var u_temp2:uint = d * u_temp1;
			var u:uint = rotl(u_temp2, 5);
			
			var t_temp1:uint = (b + b + 1);
			var t_temp2:uint = b * t_temp1;
			var t:uint = rotl(t_temp2, 5);
			
			a = rotl(a ^ t, u) + l_key[i];
			c = rotl(c ^ u, t) + l_key[i + 1];
			
			retArr[0] = a;
			retArr[1] = c;
			
			return retArr;
		}
		
		private function i_rnd(i:int,a:uint,b:uint,c:uint,d:uint):Vector.<uint>{
			var retArr:Vector.<uint> = new Vector.<uint>(2);
			var u_temp1:uint = (d + d + 1);
			var u_temp2:uint = d * u_temp1;
			var u:uint = rotl(u_temp2, 5);
			
			var t_temp1:uint = (b + b + 1);
			var t_temp2:uint = b * t_temp1;
			var t:uint = rotl(t_temp2, 5);
			c = rotr(c - l_key[i + 1], t) ^ u;
			a = rotr(a - l_key[i], u) ^ t;
			
			retArr[0] = a;
			retArr[1] = c;
			
			return retArr;
		}
		
		/**
		 * 设置key
		 * */
		public function rc6_set_key(in_key:ByteArray, arg:String = ""):void {
			
			var key_len:int = in_key.length * 8;
			var i:uint = 0;
			var j:uint = 0;
			var k:uint = 0;
			var a:uint = 0;
			var b:uint = 0;
			var t:int;
			var l:Vector.<uint> = new Vector.<uint>(8);
			l_key[0] = 0xb7e15163;
			
			for(k = 1; k < 44; ++k){
				l_key[k] = l_key[k - 1] + 0x9e3779b9;
			}
			in_key.position = 0;
			for(k = 0; k < key_len / 32; ++k){
				l[k] = in_key.readUnsignedInt();
			}
			
			t = (key_len / 32) - 1;
			
			for(k = 0; k < 132; ++k){
				var tt:uint = l_key[i] + a + b;
				a = rotl(l_key[i] + a + b, 3);
				b += a;
				b = rotl(l[j] + b, b);
				l_key[i] = a;
				l[j] = b;
				i = (i == 43 ? 0 : i + 1);
				j = (j == t ? 0 : j + 1);
			}
		}
		
		public function helloWorld(arg:String):void {
			
		}

		private function rc6_encrypt(in_blk:Vector.<uint>):Vector.<uint>{
			var out_blk:Vector.<uint> = new Vector.<uint>(4);
			var ret:Vector.<uint> = new Vector.<uint>(2);
			
			var a:uint = in_blk[0];
			var b:uint = in_blk[1] + l_key[0];
			var c:uint = in_blk[2];
			var d:uint = in_blk[3] + l_key[1];
			
			ret = f_rnd(2, a, b, c, d);
			a = ret[0];
			c = ret[1];
			
			ret = f_rnd(4, b, c, d, a);
			b = ret[0];
			d = ret[1];
			
			ret = f_rnd(6, c, d, a, b);
			c = ret[0];
			a = ret[1];
			
			ret = f_rnd(8, d, a, b, c);
			d = ret[0];
			b = ret[1];
			
			ret = f_rnd(10, a, b, c, d);
			a = ret[0];
			c = ret[1];
			
			ret = f_rnd(12, b, c, d, a);
			b = ret[0];
			d = ret[1];
			
			ret = f_rnd(14, c, d, a, b);
			c = ret[0];
			a = ret[1];
			
			ret = f_rnd(16, d, a, b, c);
			d = ret[0];
			b = ret[1];
			
			ret = f_rnd(18, a, b, c, d);
			a = ret[0];
			c = ret[1];
			
			ret = f_rnd(20, b, c, d, a);
			b = ret[0];
			d = ret[1];
			
			ret = f_rnd(22, c, d, a, b);
			c = ret[0];
			a = ret[1];
			
			ret = f_rnd(24, d, a, b, c);
			d = ret[0];
			b = ret[1];
			
			ret = f_rnd(26, a, b, c, d);
			a = ret[0];
			c = ret[1];
			
			ret = f_rnd(28, b, c, d, a);
			b = ret[0];
			d = ret[1];
			
			ret = f_rnd(30, c, d, a, b);
			c = ret[0];
			a = ret[1];
			
			ret = f_rnd(32, d, a, b, c);
			d = ret[0];
			b = ret[1];
			
			ret = f_rnd(34, a, b, c, d);
			a = ret[0];
			c = ret[1];
			
			ret = f_rnd(36, b, c, d, a);
			b = ret[0];
			d = ret[1];
			
			ret = f_rnd(38, c, d, a, b);
			c = ret[0];
			a = ret[1];
			
			ret = f_rnd(40, d, a, b, c);
			d = ret[0];
			b = ret[1];
			
			out_blk[0] = a + l_key[42];
			out_blk[1] = b;
			out_blk[2] = c + l_key[43];
			out_blk[3] = d;
			
			return out_blk;
		}
		
		private function rc6_decrypt(in_blk:Vector.<uint>):Vector.<uint>{
			var out_blk:Vector.<uint> = new Vector.<uint>(4);
			var ret:Vector.<uint> = new Vector.<uint>(2);
			var d:uint = in_blk[3];
			var c:uint = in_blk[2] - l_key[43]; 
			var b:uint = in_blk[1];
			var a:uint = in_blk[0] - l_key[42];
			
			ret = i_rnd(40,d,a,b,c);
			d = ret[0];
			b = ret[1];
			
			ret = i_rnd(38,c,d,a,b);
			c = ret[0];
			a = ret[1];
			
			ret = i_rnd(36,b,c,d,a); 
			b = ret[0];
			d = ret[1];
			
			ret = i_rnd(34,a,b,c,d);
			a = ret[0];
			c = ret[1];
			
			ret = i_rnd(32,d,a,b,c);
			d = ret[0];
			b = ret[1];
			
			ret = i_rnd(30,c,d,a,b);
			c = ret[0];
			a = ret[1];
			
			ret = i_rnd(28,b,c,d,a);
			b = ret[0];
			d = ret[1];
			
			ret = i_rnd(26,a,b,c,d);
			a = ret[0];
			c = ret[1];
			
			ret = i_rnd(24,d,a,b,c);
			d = ret[0];
			b = ret[1];
			
			ret = i_rnd(22,c,d,a,b);
			c = ret[0];
			a = ret[1];
			
			ret = i_rnd(20,b,c,d,a);
			b = ret[0];
			d = ret[1];
			
			ret = i_rnd(18,a,b,c,d);
			a = ret[0];
			c = ret[1];
			
			ret = i_rnd(16,d,a,b,c);
			d = ret[0];
			b = ret[1];
			
			ret = i_rnd(14,c,d,a,b);
			c = ret[0];
			a = ret[1];
			
			ret = i_rnd(12,b,c,d,a); 
			b = ret[0];
			d = ret[1];
			
			ret = i_rnd(10,a,b,c,d);
			a = ret[0];
			c = ret[1];
			
			ret = i_rnd( 8,d,a,b,c);
			d = ret[0];
			b = ret[1];
			
			ret = i_rnd( 6,c,d,a,b);
			c = ret[0];
			a = ret[1];
			
			ret = i_rnd( 4,b,c,d,a);
			b = ret[0];
			d = ret[1];
			
			ret = i_rnd( 2,a,b,c,d);
			a = ret[0];
			c = ret[1];
			
			out_blk[3] = d - l_key[1];
			out_blk[2] = c;
			out_blk[1] = b - l_key[0];
			out_blk[0] = a;
			
			return out_blk;
		}
		
		/**
		 * 设置
		 */
		public function  set_key(keyStr:String):void{
			keyStr = keyStr.substr(0,32)
			var key:ByteArray =  new ByteArray();
			key.endian = Endian.LITTLE_ENDIAN;
			key.writeMultiByte(keyStr,"GB2312");
			rc6_set_key(key);
		}
		
		
		
		/**
		 * 加密
		 */
		public function encrypt(content:String):Vector.<uint>{
			var block:ByteArray =  new ByteArray();
			block.endian = Endian.LITTLE_ENDIAN;
			block.writeMultiByte(content,"GB2312");
			if (block.length % 16 != 0) {
				var trade:int =(block.length + 15)/16;
				var len:int = trade * 16;
				block.length = len;
			}
			
			var row:int = block.length/4;
			var retArr:Vector.<uint> = new Vector.<uint>();
			var iarr:Vector.<uint> = new Vector.<uint>(4);
			var t:int = 0;
			block.position = 0;
			for(var i:int = 0;i < row;i++){
				var en_num:uint = block.readUnsignedInt();
				iarr[t] = en_num;
				t++;
				if(t%4 == 0){
					var enArr:Vector.<uint> = rc6_encrypt(iarr);
					for(var j:int=0;j<enArr.length;j++){
						retArr.push(enArr[j]);
					}
					t = 0;
				}
			}
			
			return retArr;
		}
		
		/**
		 * 加密
		 */
		public function bt_encrypt(block:ByteArray):ByteArray{
			if (block.length % 16 != 0) {
				var trade:int =(block.length + 15)/16;
				var len:int = trade * 16;
				block.length = len;
			}
			
			var row:int = block.length/4;
			var retArr:ByteArray = new ByteArray();
			retArr.endian = Endian.LITTLE_ENDIAN;
			var iarr:Vector.<uint> = new Vector.<uint>(4);
			var t:int = 0;
			block.position = 0;
			for(var i:int = 0;i < row;i++){
				var en_num:uint = block.readUnsignedInt();
				iarr[t] = en_num;
				t++;
				if(t%4 == 0){
					var enArr:Vector.<uint> = rc6_encrypt(iarr);
					for(var j:int=0;j<enArr.length;j++){
						retArr.writeUnsignedInt(enArr[j]);
					}
					t = 0;
				}
			}
			return retArr;
		}
		
		/**
		 * 解密
		 */
		public function decrypt(src:Vector.<uint>):String{
			var block:ByteArray =  new ByteArray();
			block.endian = Endian.LITTLE_ENDIAN;
			var iarr:Vector.<uint> = new Vector.<uint>(4);
			var t:int = 0;
			for(var i:int = 0;i < src.length;i++){
				iarr[t] = src[i];
				t++;
				if(t%4 == 0){
					var enArr:Vector.<uint> = rc6_decrypt(iarr);
					t = 0;
					for(var j:int=0;j<enArr.length;j++){
							block.writeUnsignedInt(enArr[j]);
					}
				}
			}
			block.position = 0;
			var str:String = block.readMultiByte(block.length,"GB2312");
			return str;
		}
		
		/**
		 * 解密
		 */
		public function bt_decrypt(src:ByteArray):ByteArray{
			var block:ByteArray =  new ByteArray();
			block.endian = Endian.LITTLE_ENDIAN;
			block.position = 0;
			var iarr:Vector.<uint> = new Vector.<uint>(4);
			var t:int = 0;
		
			for(var i:int = 0;i < src.length/4;i++){
				src.position = i*4;
				iarr[t] = src.readUnsignedInt();
				t++;
				if(t%4 == 0){
					var enArr:Vector.<uint> = rc6_decrypt(iarr);
					t = 0;
					for(var j:int=0;j<enArr.length;j++){
						block.writeInt(enArr[j]);
					}
				}
			}
			src.length=0;
			src.writeBytes(block,0,block.length);
			src.position=0;
			return src;
		}
	}
}