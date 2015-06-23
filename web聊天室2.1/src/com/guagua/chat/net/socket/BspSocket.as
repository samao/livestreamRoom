package com.guagua.chat.net.socket 
{
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.bsp.BspCmdHandler;
	import com.guagua.chat.net.socket.BaseSocket;
	import com.guagua.chat.net.socket.ISocketHandler;
	import com.guagua.utils.ConstVal;
	import flash.events.TimerEvent;
	import flash.utils.Endian;
	//import flash.utils.Timer;
	/**
	 * ...Bsp服务 Socket
	 * @author Wen
	 */
	public class BspSocket extends BaseSocket
	{
		//private var timer:Timer = new Timer(5000);
		
		public function BspSocket() 
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
			hasConnected = true;
			this.handler.socketConnComplete();
			
		}
		
		//关闭完成
		override public function closeToDo(arg:String):void {
			if (!hasConnected) {
				hasConnected = false;
				Log.out("BSP断开连接："+arg, this._serverIp, this._port);
				var ip:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_BSP)
				if (ip != null) {	
					this.port = ip.port;
					this.serverIp = ip.ip;
					RoomModel.getRoomModel().setIp(ip.ip, ip.port, ConstVal.SERVER_TYPE_BSP);
				}	
			}			
			//this.againConnect();		
		}
		
	}
	
}