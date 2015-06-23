package com.guagua.chat.net.socket {
	import com.guagua.chat.util.HashMap;

	/**
	 * ...
	 * @author Wen
	 */
	public class SocketManager {
		private static var instance:SocketManager;
		private var sockets:HashMap;

		public function SocketManager(){
			sockets = new HashMap();
		}

		public static function getSocketManager():SocketManager {
			if (instance == null){
				instance = new SocketManager();
			}
			return instance;
		}

		/**
		 * socketName:名称
		 * socketName:名称
		 */
		public function getSocket(socketName:String, isCreate:Boolean = true):ISocket {
			var socket:ISocket = sockets.get(socketName) as ISocket;
			if (socket == null && isCreate){
				socket = ConnectFactory.getConnectFactory().createOneConnect(socketName);
				sockets.put(socket.name, socket);
			}
			return socket;
		}
		/**
		 * 册除socket
		 */
		public function destroyOneSocket(name:String):void{
			var socket:ISocket;
			socket = sockets.remove(name) as ISocket;
			if(socket==null){
				throw new ArgumentError("socket is null!");
			}else{
				socket.GC();
				socket.sClose();
			}
		}

	}

}