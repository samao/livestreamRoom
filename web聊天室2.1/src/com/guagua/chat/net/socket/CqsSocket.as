package com.guagua.chat.net.socket
{
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.BaseSocket;
	import com.guagua.chat.net.socket.ISocketHandler;
	import com.guagua.utils.ConstVal;
	import flash.utils.Endian;
	/**
	 * CQS 超级礼物
	 *@author weiwen
	 */
	public class CqsSocket extends BaseSocket
	{		
		
		public function CqsSocket()
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
		//连接关闭
		override public function closeToDo(arg:String):void {
			this.handler.socketCloseComplete();	
			if (!hasConnected) {
				hasConnected = false;
				var roomModel:RoomModel = RoomModel.getRoomModel();				
				roomModel.setServerStatusByIp(roomModel.cqsIp, roomModel.cqsPort, false, ConstVal.SERVER_TYPE_CQS);
				//Log.out(roomModel.serversToString(ConstVal.SERVER_TYPE_CQS));
				var ip:IpInfo = roomModel.getServer(ConstVal.SERVER_TYPE_CQS)
				if (ip != null) {
					this.serverIp = ip.ip;
					this.port = ip.port;
					roomModel.setIp(ip.ip, ip.port, ConstVal.SERVER_TYPE_CQS);
					Log.out("cqs重连:", arg, JSON.stringify(ip));
				}	
			}			
			this.againConnect();
		}
		
	}
}