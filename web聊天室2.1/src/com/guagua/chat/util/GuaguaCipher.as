package com.guagua.chat.util
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.prng.*;
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.*;
	import com.guagua.chat.model.RoomModel;
	
	import flash.utils.ByteArray;
	
	public class GuaguaCipher
	{
		private static var instance:GuaguaCipher = null;
		
		public static function getInstance():GuaguaCipher{
			if(instance == null){
				instance = new GuaguaCipher();
			}
			return instance;
		}
		
		/**
		 * AES ECB 加密
		 * keyStr  加密key
		 * content 需要加密的内容 字符串  字节
		 */
		public function AesECBEncrypt(content:*,myKey:ByteArray):ByteArray{
			var block:ByteArray = new ByteArray();
			//var key:ByteArray =  new ByteArray();
			if(content is String){
				block.writeMultiByte(content,"GB2312");
			}else{
				block.writeBytes(content,0,content.length);
				for(var i:int=0;i<content.length;i++){
					//trace(content.readByte());
				}
			}
			
			//key.writeMultiByte(myKey,"GB2312");
			
//			trace(block.length);
			//加密串长度16的整数倍，不足者补足
			if (block.length % 16 != 0) {
				var trade:int =(block.length + 15)/16;
				var len:int = trade * 16;
				block.length = len;
			}
			var ecb:ECBMode = new ECBMode(new AESKey(myKey), new NullPad);
			
			ecb.encrypt(block);
			
			return block;
		}
		
		/**
		 * AES ECB 解密
		 * keyStr  加密key
		 * content 需要解密的内容
		 */
		public function AesECBDecrypt(content:ByteArray,myKey:ByteArray):ByteArray{
			/*var key:ByteArray =  new ByteArray();
			if(myKey is String){
				key.writeMultiByte(myKey,"GB2312");
			}else{
				key=myKey;
			}*/
			var ecb:ECBMode = new ECBMode(new AESKey(myKey), new NullPad);
			ecb.decrypt(content);		
			return content;
		}
		
		
	}
}