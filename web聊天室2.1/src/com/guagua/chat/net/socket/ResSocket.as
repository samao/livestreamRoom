package com.guagua.chat.net.socket 
{
	import flash.utils.Endian;
	/**
	 * ...
	 * @author idzeir
	 */
	public class ResSocket extends BaseSocket 
	{
		
		public function ResSocket() 
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
		//连接完成
		override public function connectComplete():void {
			
			//this.handler.wcmd(8000);
			
			this.handler.socketConnComplete();
		}
		//关闭完成
		override public function closeToDo(arg:String):void {
			if (this.connected) {
				this.close();				
				Log.out("Res断开连接：" + arg, this._serverIp, this._port);
				this.GC();
			}
		}
		
		
		
	}

}