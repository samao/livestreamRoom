package com.guagua.chat.Server
{
	//import com.adobe.serialization.json.JSON;
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.ISocket;
	import com.guagua.chat.net.socket.ISocketHandler;
	import com.guagua.chat.net.socket.SecuritySocket;
	import com.guagua.chat.net.socket.SocketManager;
	import com.guagua.utils.ConstVal;
	
	import flash.external.ExternalInterface;

	public class CqsProxy
	{
		private var cqsSecurIty:SecuritySocket;
		private var cqsSocket:ISocket;
		public function CqsProxy()
		{
		}
		
		public function loginRoomProxy():void {			
			if (cqsSecurIty != null) {
				cqsSecurIty.is843 = false;
			}
			
			initRoomSocket(true);
			//initSecurity();
			/*if(cqsSocket==null){
				cqsSocket = SocketManager.getSocketManager().getSocket("cqsSocket");
			}
			cqsSocket.connectServer(RoomModel.getRoomModel().cqsIp, RoomModel.getRoomModel().cqsPort);*/
		}
		
		private function initSecurity():void {
			if(cqsSecurIty==null){
				cqsSecurIty = new SecuritySocket(initRoomSocket,"cqsSocket843");
			}
			if (cqsSecurIty.connected) {
				cqsSecurIty.close();
			}
			initRoomSocket(true);
			//cqsSecurIty.connectServer(RoomModel.getRoomModel().cqsIp, RoomModel.getRoomModel().securityPort);
		}
		
		
		private function initRoomSocket(is843OK:Boolean):void {
			//trace("CqsProxy,initRoomSocket 843:",is843OK);
			if(!is843OK){
				if(ExternalInterface.available){
					var o:Object = new Object();
					o.t = 10005;
					o.type="cqs";
					o.errorServer="843";
					o.ip=RoomModel.getRoomModel().cqsIp;
					o.port=RoomModel.getRoomModel().cqsPort;
					//ExternalInterface.call("onData(" + JSON.stringify(o) + ")");
				}
				RoomModel.getRoomModel().setServerStatusByIp(RoomModel.getRoomModel().cqsIp,RoomModel.getRoomModel().cqsPort,false,ConstVal.SERVER_TYPE_CQS);
				var ip:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_CQS);
				RoomModel.getRoomModel().cqsIp = ip.ip;
				RoomModel.getRoomModel().cqsPort = ip.port;
				initSecurity();
				return;
			}
			if(cqsSocket==null){
				cqsSocket = SocketManager.getSocketManager().getSocket("cqsSocket");
			}
			
			if (!cqsSocket.connecting) cqsSocket.connectServer(RoomModel.getRoomModel().cqsIp, RoomModel.getRoomModel().cqsPort);
			
			
		}
	}
}