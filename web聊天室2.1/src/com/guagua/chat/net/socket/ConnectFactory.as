package com.guagua.chat.net.socket 
{
	import com.guagua.chat.net.handler.bsp.BspCmdHandler;
	import com.guagua.chat.net.handler.cqs.CqsCmdHandler;
	import com.guagua.chat.net.handler.res.ResCmdHandler;
	import com.guagua.chat.net.handler.room.RoomCmdHandler;
	import com.guagua.chat.net.handler.goods.GoodsCmdHandler;
	/**
	 * ...工厂  生产Socket
	 * @author weiWen
	 */
	public class ConnectFactory
	{
		public static const GOODS_SOCKET:String = "goodsSocket";
		public static const CQS_SOCKET:String="cqsSocket";
		public static const ROOM_SOCKET:String = "roomSocket";
		public static const Bsp_SOCKET:String = "bspSocket";
		public static const RES_SOCKET:String="resSocket"
		
		public static var instance:ConnectFactory;
		public function ConnectFactory() 
		{
			
		}
		
		public static function getConnectFactory():ConnectFactory {
			if (instance==null) {
				instance = new ConnectFactory();
			}
			return instance;
		}
		
		public function createOneConnect(type:String):ISocket{
			var socket:ISocket;
			var handel:ISocketHandler;
			switch(type){
				case ConnectFactory.ROOM_SOCKET:
					socket = new RoomSocket();
					handel = new RoomCmdHandler(type);
					break;
				case ConnectFactory.Bsp_SOCKET:
					socket = new BspSocket();
					handel = new BspCmdHandler(type);
				    break;
				case ConnectFactory.CQS_SOCKET:
					socket=new CqsSocket;
					handel=new CqsCmdHandler(type);
					break;
				case ConnectFactory.GOODS_SOCKET:
					socket=new GoodsSocket;
					handel = new GoodsCmdHandler(type);					
					break;
				case ConnectFactory.RES_SOCKET:
					socket = new ResSocket();
					handel = new ResCmdHandler(type);
					break
			}
			handel.socket = socket;
			socket.addHandler(handel);
			if(socket)socket.name = type;
			return socket;
		}
		
	}

}