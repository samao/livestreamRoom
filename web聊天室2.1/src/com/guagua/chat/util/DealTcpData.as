package com.guagua.chat.util 
{
	//import flash.events.EventDispatcher;
	//import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class DealTcpData 
	{
		/**原始数据*/
		private var buffer:ByteArray = new ByteArray();
		
		/**数据队列*/
		private var dataVector:Vector.<ByteArray> = new Vector.<ByteArray>();
		
		/**解包完成回调*/
		private var callFun:Function;
		
		private var isRuning:Boolean = false;
		
		public function DealTcpData(_fun:Function=null) 
		{			
			buffer.endian = Endian.LITTLE_ENDIAN;
			callFun = _fun;
		}
		
		/**写入原始数据*/
		public function push(byte:ByteArray):void {
			buffer.position = 0;
			byte.readBytes(buffer, buffer.length);
			unPack();
		}
		
		/**解包数据*/
		private function unPack():void {
			isRuning = true;
			buffer.position = 0;
			if (buffer.length < 14) {
				//数据长度不足;
				fillByte();
				return;
			}			
			try {	
				//包头			
				var head3:uint = buffer.readByte();//1字节
				
				var head2:uint = buffer.readByte();//1字节
				
				var head1:uint=buffer.readByte();//1字节
				
				//版本
				var version:uint=buffer.readByte();//1字节
				
				//时间
				var time:Number=buffer.readUnsignedShort();//2字节
				
				//加密类型
				var enType:uint=buffer.readByte();//1字节
				
				//数据体长度
				var len:uint = buffer.readUnsignedShort();//2字节
				
				//填充
				var fillData:Number = buffer.readUnsignedShort();//2字节
				
				//数据体
				var body:ByteArray = new ByteArray();
				body.endian = Endian.LITTLE_ENDIAN;
				
				buffer.readBytes(body, 0, len);
				
				//包尾
				var tail6:uint = buffer.readByte();//1字节
				
				var tail5:uint = buffer.readByte();//1字节
				
				var tail4:uint = buffer.readByte();//1字节
			}catch (error:Error) {
				fillByte();
				return;
			}
			
			var isHead:Boolean = (head3 == 3 && head2 == 2 && head1 == 1);
			var isTail:Boolean = (tail6 == 6 && tail5 == 5 && tail4 == 4);
			
			if (!isHead || ! isTail) {
				fillByte();
				return;
			}
			//trace("DealTCP:", body, enType);
			callFun(body, enType);
			cutByteArray();
		}
		
		private function fillByte():void {
			return;
			if (dataVector.length > 0) {
				buffer.position = 0;
				var byte:ByteArray = dataVector.splice(0, 1)[0];
				byte.readBytes(buffer, buffer.length);
				unPack();
				return;
			}
			isRuning = false;
		}
		
		/**解包完成，重新组数据*/
		private function cutByteArray():void {
			if (buffer.length >= 0) {
				var byte:ByteArray = new ByteArray();
				byte.endian = Endian.LITTLE_ENDIAN;
				
				buffer.readBytes(byte);
				buffer.clear();
				
				byte.readBytes(buffer);
				unPack();
				return;
			}
			isRuning = false;
		}		
		
	}

}