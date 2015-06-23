package com.guagua.chat.Server
{
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.ISocket;
	import com.guagua.chat.net.socket.SecuritySocket;
	import com.guagua.chat.net.socket.SocketManager;
	import com.guagua.utils.ConstVal;
	//import com.adobe.serialization.json.JSON;
	
	import flash.external.ExternalInterface;
	public class GoodsProxy
	{
		private var goodsSecurIty:SecuritySocket;
		private var goodsSocket:ISocket;
		public function GoodsProxy()
		{
		}
		
		public function loginRoomProxy():void {	
			if (goodsSecurIty != null) {
				goodsSecurIty.is843 = false;
			}
			
			initRoomSocket(true);
			//initSecurity();
			/*if(goodsSocket==null){
				goodsSocket = SocketManager.getSocketManager().getSocket("goodsSocket");
			}
			goodsSocket.connectServer(RoomModel.getRoomModel().goodsIp, RoomModel.getRoomModel().goodsProt);*/
		}
		
		private function initSecurity():void {
			if(goodsSecurIty==null){
				goodsSecurIty = new SecuritySocket(initRoomSocket,"goodSocket843");
			}
			if (goodsSecurIty.connected) {
				goodsSecurIty.close();
			}
			initRoomSocket(true);
			//goodsSecurIty.connectServer(RoomModel.getRoomModel().goodsIp, RoomModel.getRoomModel().securityPort);
		}
		
		private function initRoomSocket(is843OK:Boolean):void {
			//trace("GoodsProxy,initRoomSocket 843:",is843OK);
			if(!is843OK){
				if(ExternalInterface.available){
					var o:Object = new Object();
					o.t = 10005;
					o.type="acs";
					o.errorServer="843";
					o.ip=RoomModel.getRoomModel().goodsIp;
					o.port=RoomModel.getRoomModel().goodsProt;
					//ExternalInterface.call("onData(" + JSON.stringify(o) + ")");	
					
				}
				RoomModel.getRoomModel().setServerStatusByIp(RoomModel.getRoomModel().goodsIp,RoomModel.getRoomModel().goodsProt,false,ConstVal.SERVER_TYPE_ACS);
				var ip:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_ACS);
				RoomModel.getRoomModel().goodsIp = ip.ip;
				RoomModel.getRoomModel().goodsProt = ip.port;
				initSecurity();
				return;
			}
			if (goodsSocket == null) {
				Log.out("计费：", RoomModel.getRoomModel().goodsIp, RoomModel.getRoomModel().goodsProt);
				goodsSocket = SocketManager.getSocketManager().getSocket("goodsSocket");
			}
			
			if (!goodsSocket.connecting) goodsSocket.connectServer(RoomModel.getRoomModel().goodsIp, RoomModel.getRoomModel().goodsProt);
			
			
		}
	}
}