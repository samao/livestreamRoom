package com.guagua.chat.net.handler.res
{
	//import com.adobe.serialization.json.JSON;
	import com.guagua.chat.net.handler.HandlerMap;
	import flash.utils.setTimeout;
	//import com.guagua.chat.model.ResNode;
	import com.guagua.chat.model.ResTree;
	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.socket.CmdSocketHandel;
	//import com.guagua.chat.util.GuaguaCipher;
	import com.guagua.chat.util.Operation;
	import com.guagua.chat.util.RC6;
	import com.guagua.utils.ConstVal;
	
	//import flash.events.TimerEvent;
	import flash.external.*;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	//import flash.utils.Timer;
	

	/**
	 *
	 * @author Wen
	 */
	public class ResCmdHandler extends CmdSocketHandel
	{
		private var write:ResWriteData;	
		
		public function ResCmdHandler(cmd:String)
		{
			super(cmd);	
			
			eType = 0;
			write = new ResWriteData();			
					
			
			this.cmds = [8001,8005];
			
			
			this.resetKey();
			RC6.getInstance().rc6_set_key(keyBty,"BSP");
			
			write.keyBty=keyBty;
			write.eType=eType;				
			
		}
		
		//初始化
		override public function socketConnComplete():void {
			this.whandle(this.write._8000(0));	

			setTimeout(checkResvalid, 8000);
		}
			
		/**
		 * 超过8秒不回包，切换地址
		 */
		private function checkResvalid():void
		{
			if (!ResTree.isReady)
			{
				socket.changeIpAndConnect("服务器没有回包");
			}	
		}
		
		override public function resetKey():void{
			keyBty.length=0;
			keyBty.endian=Endian.LITTLE_ENDIAN;
			keyBty.writeMultiByte(RoomModel.getRoomModel().resKey,"GB2312");
		}
		
		//是否返回数据
		public function isAgainConnect():Boolean{
			return false;
		}
		/*//结构体
		override public function handle(body:ByteArray, type:int = 0):Boolean {
			if (type != 0) {				
				super.handle(body,type);	
			}
					
			var cmdId:int = body.readShort();
			//if(cmdId!=1035&&cmdId!=8001)trace(this.cmds.indexOf(cmdId)>=0?"有包":"无包",cmdId,"BSP",type)
			body.position=2;
			if (cmds.indexOf(cmdId) >= 0) {
						
				this["_"+cmdId](body);
			}
			return false;
		}*/
		
		override public function handle(body:ByteArray, type:int = 0):Boolean {
			if (type != 0) {				
				super.handle(body,type);	
			}
			
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			localHandlerMap.put(body, 2);			
			handleData();
			return true;
		}
		
		private function handleData():void {
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			if (!localHandlerMap.hasByte(2)) {				
				return
			}
			var body:ByteArray = localHandlerMap.getByte(2);
			var cmdId:int = body.readShort();			
			if (cmds.indexOf(cmdId) >= 0) {				
				this["_"+cmdId](body);
			}
			handleData();
		}
		
		//执行解包
		override public function wcmd(cmd:int):void {
			this["_" + cmd]();
			return;
		}
		
		
		/**资源信息通知包*/
		public function _8001(body:ByteArray, type:uint = 8001):void {
			body.readByte();
			Operation.getOperation().readLong(body);// 最后修改时间
			
			var obj:Object = new Object();
			obj.resID = body.readInt();
			obj.grade = Operation.getOperation().readLong(body) & 0x1F;
			obj.name = Operation.getOperation().readGB2312String(body);
			obj.des = Operation.getOperation().readGB2312String(body);
			
			//var resNode:ResNode = new ResNode(obj);
			
			var resTree:ResTree = ResTree.getInstance();
			resTree.addRes(obj.resID);
			
			//trace("资源总数：",resTree.size);
			//_8000Ok = true;
		}
		
		/**资源下载状态通知包*/
		public function _8005(body:ByteArray, type:uint = 8005) {
			var obj:Object = new Object();
			obj.m_byResType=body.readByte();//资源类型
			obj.m_byStatus=body.readByte();//下载状态，默认0,下载完成1
			obj.m_lParam=body.readInt();//其它参数
			obj.m_i64ChangeTime=Operation.getOperation().readLong(body);//修改时间
			
			ResTree.isReady = true;
			Log.out("资源下载完成：", JSON.stringify(obj));
			this.socket.connectWatcher();	
			this.socket.closeToDo("");
		}	
		
		
	}
}