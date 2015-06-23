package com.guagua.chat.util
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	
	public class RC6Test extends Sprite
	{
		public function RC6Test()
		{
			var rc6Handel:RC6 = RC6.getInstance();
			rc6Handel.set_key("77CBC149-A49F-48F9-B17A-6A3EA9B4");
//			var retArr:Vector.<uint> =  rc6Handel.encrypt("d你好!北京欢迎你。你好!北京欢迎你。防辐射服 llllll");
//			var str:String = rc6Handel.decrypt(retArr);
		
			var content:String = "fff大扫荡dfsdfdf";
			var block:ByteArray =  new ByteArray();
			block.endian = Endian.LITTLE_ENDIAN;
			block.writeMultiByte(content,"GB2312");
			var retArrat:ByteArray = rc6Handel.bt_encrypt(block);
			
			var de_arrat:ByteArray = rc6Handel.bt_decrypt(retArrat);
			de_arrat.position = 0;
			var str:String = de_arrat.readMultiByte(de_arrat.length,"GB2312");
			trace(str);
		}
	}
}