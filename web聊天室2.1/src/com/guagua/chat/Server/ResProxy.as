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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import flash.external.ExternalInterface;

	public class ResProxy extends EventDispatcher
	{
		private var resSecurIty:SecuritySocket;
		private var resSocket:ISocket;
		
		public function ResProxy(tar:IEventDispatcher=null)
		{
			super(tar);
		}
		
		public function loginResProxy():void {
			if (resSecurIty != null) {
				resSecurIty.is843 = false;
			}
			
			initResSocket(true);
			//initSecurity();
			/*if(cqsSocket==null){
				cqsSocket = SocketManager.getSocketManager().getSocket("cqsSocket");
			}
			cqsSocket.connectServer(RoomModel.getRoomModel().cqsIp, RoomModel.getRoomModel().cqsPort);*/
			//Log.out("loginResProxy")
		}
		
		private function initSecurity():void {
			if(resSecurIty==null){
				resSecurIty = new SecuritySocket(initResSocket,"resSocket843");
			}
			if (resSecurIty.connected) {
				resSecurIty.close();
			}
			initResSocket(true);
			//Log.out("InitSecurity:");
			//resSecurIty.connectServer(RoomModel.getRoomModel().bspIp, 843);
		}
		
		public function backFun():void {
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function changeIP():void {
			Log.out("连不上切换res服务器")
			//ErrorToServerMgr.getLocal().add( { errorID:109, serverIp:RoomModel.getRoomModel().bspIp, serverPort:RoomModel.getRoomModel().bspProt } );
			RoomModel.getRoomModel().setServerStatusByIp(RoomModel.getRoomModel().bspIp,RoomModel.getRoomModel().bspProt,false,ConstVal.SERVER_TYPE_BSP);
			var ip:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_BSP);
			if (ip != null) {
				RoomModel.getRoomModel().bspIp = ip.ip;
				RoomModel.getRoomModel().bspProt = ip.port;				
			}
			initSecurity();
		}
		
		
		private function initResSocket(is843OK:Boolean):void {
			Log.out("RESProxy,initResSocket 843:", is843OK);
			if(!is843OK){				
				changeIP();
				return;
			}
			if(resSocket==null){
				resSocket = SocketManager.getSocketManager().getSocket("resSocket");
			}
			//trace("连接")
			//121.18.236.47 2909
			if (!resSocket.connecting) resSocket.connectServer(RoomModel.getRoomModel().bspIp,RoomModel.getRoomModel().bspProt,backFun);
			
			
		}
	}
}