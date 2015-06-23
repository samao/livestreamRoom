package com.guagua.chat.net.socket 
{
	import com.guagua.events.EventProxy;
	import com.guagua.events.RoomEvent;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.BaseSocket;
	import com.guagua.chat.net.socket.ISocketHandler;
	
	import flash.events.Event;
	import flash.utils.Endian;

	/**
	 * ...房间代理服务 Socket
	 * @author Wen
	 */
	public class RoomSocket extends BaseSocket
	{
		
		public function RoomSocket() 
		{
			super();
			headLen = 11;
			endian = Endian.LITTLE_ENDIAN;
		}
		/**
		 * 结构长度
		 */
		override protected function getBodyLen():int{
			buffer.position = 7;
			return buffer.readShort();
		}
		/**
		 * RoomSocket 连接成功执行
		 */
		override public function connectComplete():void {
			this.handler.socketConnComplete();
		}
		/**
		 * RoomSocket关闭完成执行
		 */
		override public function closeToDo(arg:String):void {
			//trace(this.handler["is1002"],arg)
			if(this.handler["is1002"]){
				this.handler.socketCloseComplete();
			}else {
				EventProxy.instance().dispatchEvent(new RoomEvent(RoomEvent.Event_Socket_Cas_Ip_Err));
			}
			
		}
		/**
		 * RoomSocket 重新设置密码后，当做连接成功处理(登录);
		 */
		public function setPwdComplete():void {			
			if(this.connected){
				this.handler.socketConnComplete();
			}
			//this.againConnect();
		}
		
	}

}