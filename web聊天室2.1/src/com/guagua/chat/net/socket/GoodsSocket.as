package com.guagua.chat.net.socket 
{
	import com.guagua.chat.net.socket.BaseSocket;
	import com.guagua.chat.net.socket.ISocketHandler;
	import flash.utils.Endian;
	/**
	 * ...计费服务Socket
	 * @author Wen
	 */
	public class GoodsSocket extends BaseSocket
	{
		
		public function GoodsSocket() 
		{
			super();
			headLen = 11;
			endian = Endian.LITTLE_ENDIAN;
		}
		//结构长度
		override protected function getBodyLen():int{
			buffer.position = 7;
			return buffer.readShort();
		}
		//连接成功执行
		override public function connectComplete():void {
			//trace(this.name);
			this.handler.socketConnComplete();
			//this.handler.wcmd(62);
			//this.handler.wcmd(1111);
		}
		//关闭执行
		override public function closeToDo(arg:String):void {
			this.handler.socketCloseComplete();
		}
	}

}