package com.guagua.chat.net.socket 
{
	//import com.adobe.serialization.json.JSON;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.util.GuaguaCipher;
	import com.guagua.chat.util.RC6;
	
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...处理消息基本方法
	 * @author Wen
	 */
	public class CmdSocketHandel implements ISocketHandler
	{
		
		protected var _cmd:String;
		protected var _socket:ISocket;
		private var _cmds:Array;
		private var _writecmds:Array;
		
		//加密 解密key
		protected var keyBty:ByteArray;
		//加密类型
		protected var eType:int=0;		
		
		
		public function CmdSocketHandel(cmd:String)
		{
			//trace("handle:"+cmd);
			this._cmd = cmd;
			keyBty=new ByteArray();
			keyBty.endian=Endian.LITTLE_ENDIAN;
			keyBty.writeMultiByte(RoomModel.getRoomModel().initKey,"GB2312");			
			
		}
		
		public function resetKey():void{
			keyBty.length=0;
			keyBty.endian=Endian.LITTLE_ENDIAN;
			keyBty.writeMultiByte(RoomModel.getRoomModel().initKey,"GB2312");
		}

		public function handle(body:ByteArray,type:int=0):Boolean
		{
			eType=type;
			if(eType==1){
				GuaguaCipher.getInstance().AesECBDecrypt(body,keyBty);
			}
			if(eType==2){
				RC6.getInstance().bt_decrypt(body);
			}
			body.position=0;
			return false;
		}
		
		public function whandle(body:ByteArray):Boolean
		{
			_socket.sendMessage(body);
			return false;
		}
		
		public function set socket(socket:ISocket):void
		{
			this._socket = socket;
		}
		
		public function get socket():ISocket
		{
			return this._socket;
		}
		
		public function get command():String
		{
			return _cmd;
		}
		public function set cmds(cmds:Array):void{
			this._cmds = cmds;
		}
		public function get cmds():Array{
			return _cmds;	
		}
		
		public function set wcmds(wcmds:Array):void{
			this._writecmds = wcmds;
		}
		public function get wcmds():Array{
			return _writecmds;	
		}
		
		public function wcmd(cmd:int):void {
			this["_" + cmd]();
			//trace(cmd);
			return;
		}
		//socket连接成功
		public function socketConnComplete():void{
			
		}
		//socket关闭成功
		public function socketCloseComplete():void{
			
		}
		
		public function gc():void{
			this.socket=null;
		}
		
		protected function sendToJsObj(obj:Object):void {
			if(ExternalInterface.available){				
				try {
					ExternalInterface.call("onData",obj);
					//ExternalInterface.call("onData(" + JSON.stringify(obj) + ")");
				}catch (e:Error) {
					Log.out("未定义js函数onData()", JSON.stringify(obj));
				}
			}
		}
		
		
	}

}