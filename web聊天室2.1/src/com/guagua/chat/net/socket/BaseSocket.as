package com.guagua.chat.net.socket 
{
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.ISocketHandler;
	import com.guagua.chat.util.DealTcpData;
	import com.guagua.utils.ConstVal;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import com.guagua.events.RoomEvent;
    
	/**
	 * ...socket基类   接收数据 解读完整包
	 * @author Wen
	 */
	public class BaseSocket extends Socket implements ISocket
	{
		/**
		 * 名称  唯一标识
		 */
		private var _name:String;
		/**
		 * 服务器 ip
		 */
		public var _serverIp:String;
		/**
		 * 端口
		 */
		public var _port:int;
		/**
		 * 存储数据
		 */
		protected var buffer:ByteArray;
        /**
		 * 包头长度
		 */
		protected var headLen:int = 17;
		/**
		 * 包尾长度
		 */
		protected var endLen:int = 3;
		/**
		 * 解包类
		 */
		protected var handler:ISocketHandler;
		/**
		 * 加密类型 1:加密 0:不加密
		 */
		protected var eType:int = 0;
		
		
		/**连接过程状态*/
		public var isConnecting:Boolean = false;		
		
		public var callFun:Function;
		
		/**解TCP底层包*/
		public var dealTcp:DealTcpData;
		
		protected var hasConnected:Boolean = false;
		
		public function BaseSocket()
		{	
			dealTcp = new DealTcpData(backCall);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrHandel);
			addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			addEventListener(Event.CLOSE,closedHandler);
			addEventListener(Event.CONNECT,connectHandler);
			addEventListener(ProgressEvent.SOCKET_DATA,dataHandler);
			this.endian = Endian.LITTLE_ENDIAN;
			this.timeout = 5000;
			
		}		
		
		
		protected function dataHandler(e:ProgressEvent):void {
			var byte:ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			
			readBytes(byte);
			//unPack(byte);
			dealTcp.push(byte);
		}		
		
		private function backCall(body:ByteArray, eType:int):void {
			//trace("BackCALL",body.readShort())
			body.position = 0;
			if (handler) {				
				handler.handle(body,eType);
			}
		}
			
		
		/**
		 * 获取消息体的长度
		 * @return body's length
		 * 
		 */		
		protected function getBodyLen():int{	
			return 0;
		}
		protected function connectHandler(e:Event):void{
			
			if(!buffer)buffer = new ByteArray();
			buffer.endian = Endian.LITTLE_ENDIAN;
			buffer.length = 0;	
			isConnecting = false;
			Log.out("socket连接成功：", this.name, this._serverIp, this._port);
			connectComplete();	
		}
		/**
		 * 关闭函数
		 */
		protected function closedHandler(e:Event):void {
			//trace(_name+":Socket close");
			isConnecting = false;
			closeToDo(e.type);
		}
		protected function securityErrHandel(e:SecurityErrorEvent):void{
			Log.out(_name + "  843  securityErrHandel");
			//ErrorToServerMgr.getLocal().add( { errorID:101, serverIp:this._serverIp, serverPort:this._port,col1:_name } );
			isConnecting = false;
			
			changeIpAndConnect(e.type);
			//setImmediatelyClose(e.type);
		}
		protected function errorHandler(e:ErrorEvent):void{
			//trace(_name+"  BaseSocket  errorHandler");
			isConnecting = false;
			
			changeIpAndConnect(e.type);
			//setImmediatelyClose(e.type);
		}
		public function set name(name:String):void{
			this._name = name;
		}
		public function get name():String{
			return this._name;	
		}
		/**
		 * 连接服务器
		 */
		public function connectServer(serverIp:String, port:int,backCall:Function=null):void {
			isConnecting = true;
			this._serverIp = serverIp;
			this._port = port;
			callFun = backCall;
			
			connect(this._serverIp,this._port);
		}
		
		public function get connectWatcher():Function {
			return callFun;
		}
		
		public function get serverIp():String{
			return this._serverIp;
		}
		public function set serverIp(serverIp:String):void{
			this._serverIp = serverIp;
		}
		public function get port():int{
			return this._port;
		}
		public function set port(port:int):void{
			this._port = port;
		}
		/**
		 * 册除解包类
		 */
		public function removeHandler():void{
			if(handler){
				//handler.socket = null;
				handler.gc();
				handler = null;
			}
		}
		public function againConnect():void {
			Log.out("socket重连了：",this.name,this._serverIp,this._port)
			connect(this._serverIp,this._port);			
		}
		public function addHandler(handlerCmd:ISocketHandler) : void
		{
			handler = handlerCmd;
		}
		public function sendMessage(msg:ByteArray):void {	
			if (!this.connected)
			{
				Log.out(this._name, "未连接不能发包")
				
				return;
			}
			this.writeBytes(msg);
			this.flush();		
		}
		public function setImmediatelyClose(arg:String):void{
			//trace("BaseSocket setImmediatelyClose",this.connected);
			if(this.connected){
				this.close();				
			}else{
				closeToDo(arg);
			}
		}
		public function get connecting():Boolean{
			return this.connected;
		}
		/**
		 * socket连接成功后操作
		 */
		public function connectComplete():void{
			
		}
		/**
		 * socket关闭后操作
		 */
		public function closeToDo(arg:String):void {
			
		}
		
		public function dispathEvent(event:RoomEvent):void{
			this.dispatchEvent(event);
		}
		
		/*****************************************************************************/
		public function GC():void {
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
			removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
			removeEventListener(Event.CLOSE,closedHandler);
			removeEventListener(Event.CONNECT,connectHandler);
			removeEventListener(ProgressEvent.SOCKET_DATA,dataHandler);
			if(buffer!=null){
				buffer.length = 0;
				buffer = null;
			}
			removeHandler();
			//sClose();
		}
		
		public function sClose():void{
			if (this.connected) {
				Log.out("空闲关闭：", this.name);
				this.close();
			}
		}
		
		public function changeIpAndConnect(arg:String):void
		{
			var typeStr:String = "";			
			switch(_name)
			{
				case ConnectFactory.ROOM_SOCKET:
					typeStr = ConstVal.SERVER_TYPE_CAS;
					break;
				case ConnectFactory.Bsp_SOCKET:
					typeStr = ConstVal.SERVER_TYPE_BSP;
					break;
				case ConnectFactory.RES_SOCKET:
					typeStr = ConstVal.SERVER_TYPE_BSP;
					break;
				case ConnectFactory.CQS_SOCKET:
					typeStr = ConstVal.SERVER_TYPE_CQS;
					break;
				case ConnectFactory.GOODS_SOCKET:
					typeStr = ConstVal.SERVER_TYPE_ACS;
					break;
			}
			if (typeStr != "")
			{
				this.sClose();
				
				Log.out("引发安全问题:" + arg, typeStr, _serverIp, _port);
				RoomModel.getRoomModel().setServerStatusByIp(this._serverIp, this._port, false, typeStr);
				
				var ip:IpInfo = RoomModel.getRoomModel().getServer(typeStr);
				if (ip != null)
				{
					RoomModel.getRoomModel().setIp(ip.ip, ip.port, typeStr);
					_serverIp = ip.ip;
					_port = ip.port;
					againConnect();
				}
			}
		}
	}

}