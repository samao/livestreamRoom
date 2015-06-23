package com.guagua.chat.Server
{
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.ISocket;
	import com.guagua.chat.net.socket.SecuritySocket;
	import com.guagua.chat.net.socket.SocketManager;
	//import com.adobe.serialization.json.JSON
	import com.guagua.utils.ConstVal;
		
	import flash.external.ExternalInterface;
	public class BspProxy
	{
		private var bspSecurIty:SecuritySocket;
		private var bspSocket:ISocket;
		
		public function BspProxy()
		{
		}
		
		public function loginRoomProxy():void {
			if (bspSecurIty != null) {
				bspSecurIty.is843 = false;
			}
			
			initRoomSocket(true);
			//initSecurity();
			/*if(bspSocket==null){
				bspSocket = SocketManager.getSocketManager().getSocket("bspSocket");
			}
			bspSocket.connectServer(RoomModel.getRoomModel().bspIp, RoomModel.getRoomModel().bspProt);*/
		}
		
		private function initSecurity():void {
			if (bspSecurIty == null) {				
				bspSecurIty = new SecuritySocket(initRoomSocket,"bspSocket843");
			}
			
			if (bspSecurIty.connected) {
				bspSecurIty.close();
			}
			
			/*if (bspSocket.connecting) {
				SocketManager.getSocketManager().destroyOneSocket("bspSocket");
			}*/
			initRoomSocket(true);
			//Log.out("BSP:>",RoomModel.getRoomModel().bspIp, RoomModel.getRoomModel().securityPort)
			//bspSecurIty.connectServer(RoomModel.getRoomModel().bspIp, RoomModel.getRoomModel().securityPort);
		}
		
		private function initRoomSocket(is843OK:Boolean):void {
			
			//trace("BspProxy,initRoomSocket 843:",is843OK);
			if(!is843OK){
				if(ExternalInterface.available){
					var o:Object = new Object();
					o.t = 10005;
					o.type="bsp";
					o.errorServer="843";
					o.ip=RoomModel.getRoomModel().bspIp;
					o.port=RoomModel.getRoomModel().bspProt;
					//ExternalInterface.call("onData(" + JSON.stringify(o) + ")");
				}
				RoomModel.getRoomModel().setServerStatusByIp(RoomModel.getRoomModel().bspIp,RoomModel.getRoomModel().bspProt,false,ConstVal.SERVER_TYPE_BSP);
				var ip:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_BSP);
				RoomModel.getRoomModel().bspIp = ip.ip;
				RoomModel.getRoomModel().bspProt = ip.port;
				initSecurity();
				return;
			}
			
			
			
			if(bspSocket==null){
				bspSocket = SocketManager.getSocketManager().getSocket("bspSocket");
			}
			
			if (!bspSocket.connecting) bspSocket.connectServer(RoomModel.getRoomModel().bspIp, RoomModel.getRoomModel().bspProt);
			
			
		}
	}
}