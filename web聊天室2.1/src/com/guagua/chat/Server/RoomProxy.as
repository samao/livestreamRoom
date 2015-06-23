package com.guagua.chat.Server
{
	//import com.guagua.chat.net.web.WebDataLoader;
	//import com.adobe.serialization.json.JSON;
	import com.guagua.events.EventProxy;
	import com.guagua.events.RoomEvent;
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.ISocket;
	import com.guagua.chat.net.socket.RoomSocket;
	import com.guagua.chat.net.socket.SecuritySocket;
	import com.guagua.chat.net.socket.SocketManager;
	import com.guagua.utils.ConstVal;
	
	import flash.events.Event;
	//import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	/**
	 * 房间代理 roomProxy
	 * @author weiwen
	 */
	public class RoomProxy
	{
		/**
		 * 策略socket
		 */
		private var roomSecurIty:SecuritySocket;
		/**
		 * cas Socket
		 */
		private var roomSocket:RoomSocket;
		public function RoomProxy()
		{
			EventProxy.instance().addEventListener(RoomEvent.Event_Socket_Cas_Ip_Err,casIpErrHandler);
		}
		/**
		 * 登陆
		 */
		public function loginRoomProxy():void {
			if (roomSecurIty != null) {
				roomSecurIty.is843 = false;
			}
			//initSecurity();
			initRoomSocket(true);
		}
		/**
		 * 843 策略
		 */
		private function initSecurity():void {
			if(roomSecurIty==null){
				roomSecurIty = new SecuritySocket(initRoomSocket,"roomSocket843");
			}
			Log.out("roomProXy尝试连接843:", RoomModel.getRoomModel().roomProxyIp, RoomModel.getRoomModel().securityPort)
			if (roomSecurIty.connected) {
				roomSecurIty.close();
			}
			
			/*if (roomSocket.connecting) {
				SocketManager.getSocketManager().destroyOneSocket("roomSocket");
			}*/
			initRoomSocket(true);
			//roomSecurIty.connectServer(RoomModel.getRoomModel().roomProxyIp, RoomModel.getRoomModel().securityPort);
		}
		/**
		 * 843socket回调函数
		 */
		private function initRoomSocket(is843OK:Boolean):void {
		//	trace("RoomProxy,initRoomSocket 843:",is843OK);
			if(!is843OK){
				/*if(ExternalInterface.available){
					var o:Object = new Object();
					o.t = 10005;
					o.type="cas";
					o.errorServer="843";
					o.ip=RoomModel.getRoomModel().roomProxyIp;
					o.port=RoomModel.getRoomModel().roomProxyPort;
					ExternalInterface.call("onData(" + JSON.stringify(o) + ")");
				}*/	
				var ipStr:String = RoomModel.getRoomModel().roomProxyIp;
				var port843:Number = RoomModel.getRoomModel().securityPort;
				Log.out("roomProXy尝试连接843失败:", ipStr, port843)
				
				//ErrorToServerMgr.getLocal().add( { errorID:101, serverIp:ipStr, serverPort:port843 } );
				
				cas843ErrHandler();
				return;
			}
			
			if(roomSocket==null){
				roomSocket = SocketManager.getSocketManager().getSocket("roomSocket") as RoomSocket;
			}
			if (roomSocket.connected) {
				roomSocket.close();
			}
			//ErrorToServerMgr.getLocal().addCountStr( "cas:" + RoomModel.getRoomModel().roomProxyIp + ":843" + "|" + ConstVal.date );
			Log.out("连接CAS：",RoomModel.getRoomModel().roomProxyIp, RoomModel.getRoomModel().roomProxyPort)
			roomSocket.connectServer(RoomModel.getRoomModel().roomProxyIp, RoomModel.getRoomModel().roomProxyPort);		
		}
		/**
		 * 设置密码后socket操作
		 */
		public function setPwdHandler():void {
			//跳过843验证；
			initRoomSocket(true);			
		}
		
		/**cas 843 错误**/
		private function cas843ErrHandler(e:RoomEvent = null):void {			
			
			RoomModel.getRoomModel().setServerStatusByIp(RoomModel.getRoomModel().roomProxyIp,RoomModel.getRoomModel().roomProxyPort,false);
			//var ipM:IpInfo = RoomModel.getRoomModel().getSrsIp("cas");
			var ipM:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_CAS);
			if(ipM!=null){
				RoomModel.getRoomModel().setIp(ipM.ip, ipM.port, ConstVal.SERVER_TYPE_CAS);
				this.roomSecurIty.setConnIndex();
			}else {
				Log.out("CAS列表空了，重置");
				//WebDataLoader.getInstance().isLoad = false;
				//WebDataLoader.getInstance().load();
				/*
				ipM = RoomModel.getRoomModel().resetSrsIp();
				RoomModel.getRoomModel().setIp(ipM.ip, ipM.port, "cas");
				this.roomSecurIty.setConnIndex();*/
			}
			initSecurity();
		}
		
		/**cas ip错误**/
		private function casIpErrHandler(e:RoomEvent = null):void {
			//ErrorToServerMgr.getLocal().add( { errorID:102, serverIp:RoomModel.getRoomModel().roomProxyIp, serverPort:RoomModel.getRoomModel().roomProxyPort } );
			
			RoomModel.getRoomModel().setServerStatusByIp(RoomModel.getRoomModel().roomProxyIp,RoomModel.getRoomModel().roomProxyPort,false);
			var ipM:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_CAS);
			if(ipM!=null){
				RoomModel.getRoomModel().setIp(ipM.ip,ipM.port,ConstVal.SERVER_TYPE_CAS);
			}else {
				Log.out("CAS列表空了，重新调取js数据");
				//WebDataLoader.getInstance().isLoad = false;
				//WebDataLoader.getInstance().load();
			}
			initSecurity();
		}
		
	}
}