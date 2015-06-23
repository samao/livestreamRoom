package com.guagua.chat.net.handler.goods
{
	//import com.adobe.serialization.json.JSON;
	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.HandlerMap;
	import com.guagua.chat.net.socket.CmdSocketHandel;
	import com.guagua.chat.util.Operation;
	import com.guagua.utils.ConstVal;
	
	//import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	//import flash.utils.Timer;
	/**
	 *计费代理
	 *@anthor : weiwen
	 */
	public class GoodsCmdHandler extends CmdSocketHandel
	{
		private var write:GoodsWriteData;
		private var isLogin:int=0;
		//private var timer:Timer;
		public function GoodsCmdHandler(cmd:String)
		{
			super(cmd);
			write = new GoodsWriteData();
			this.cmds = [52,63];
			//timer=new Timer(5000,1);
			//timer.addEventListener(TimerEvent.TIMER_COMPLETE,tComplete);
		}
		//连接成功
		override public function socketConnComplete():void{
			if(isLogin==0){
				_62();
			}
		}
		
		override public function handle(body:ByteArray, type:int = 0):Boolean {
			if (type != 0) {				
				super.handle(body,type);	
			}
			
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			localHandlerMap.put(body, 1);			
			handleData();
			return true;
		}
		
		private function handleData():void {
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			if (!localHandlerMap.hasByte(1)) {				
				return
			}
			var body:ByteArray = localHandlerMap.getByte(1);
			var cmdId:int = body.readShort();			
			if (cmds.indexOf(cmdId) >= 0) {								
				this["_"+cmdId](body);
			}
			handleData();
		}
		
		//解包
		override public function wcmd(cmd:int):void {
			this["_" + cmd]();
			return;
		}
		/**
		 * 计费登陆应答
		 * @author idzeir modify:20130701
		 * */
		private function _63(body:ByteArray,type:int=63):void{			
			var obj:Object = { t:type };
			try {
				//用户ID
				obj.uid = Operation.getOperation().readLong(body);
				//其他参数
				obj.m_lOtherPara = body.readInt(); 
				//其他参数
				obj.m_lOtherPara2 = body.readInt(); 
				//结果 
				obj.m_byLoginResult = body.readByte(); //1是同意,其它是拒绝，0
				//trace("m_byLoginResult:"+obj.m_byLoginResult);
				obj.m_szErrInfo = Operation.getOperation().readGB2312String(body); //错误消息
			}catch (e:Error) {
				Log.out(type, e.message);
				return;
			}	

			isLogin = obj.m_byLoginResult;
			
			if (obj.m_byLoginResult == 1) {
				Log.out("计费服务器登录结果：",Boolean(obj.m_byLoginResult),obj.m_szErrInfo)
				_51();
			}
		}
		
		/**
		 * 用户装备
		 * @author idzeir modify:20130701
		 * */
		private function _52(body:ByteArray,type:int=63):void{
			var obj:Object = { t:type };
			try {
				///用户ID
				obj.uid = Operation.getOperation().readLong(body);
				body.readShort();
				var t:int = body.readShort();				
				var mAry:Array=[];
				for(var i:int=0;i<t;i++){
					var o:Object=new Object();
					//产品编号
					o.m_i64ID=Operation.getOperation().readLong(body);
					//基本物品ID
					o.m_lBaseGoodsID=body.readInt();
					//物品数量
					o.m_dbCount=body.readFloat();
					//o.m_dbCount=Operation.getOperation().readLong(body);
					//开始时间
					o.m_nStartTime=Operation.getOperation().readLong(body);
					//失效时间
					o.m_nEndTime=Operation.getOperation().readLong(body);
					//属性
					RoomModel.getRoomModel().myUserInfo.level = Math.floor(o.m_dbCount);					
				}
			}catch (e:Error) {
				Log.out(type, e.message);
				return;
			}
			
			RoomModel.getRoomModel().isACS = true;
			Log.out("计费52：m_szErrInfo",RoomModel.getRoomModel().myUserInfo.level,JSON.stringify(obj));
		}
		
		//是否需要重连
		private function isAgainConnect():Boolean{
			if(RoomModel.getRoomModel().myUserInfo.level!=-1)return false;
			return true;
		}
		override public function socketCloseComplete():void{
			if(isAgainConnect()){
				var o:Object = new Object();
				o.t = 10005;
				o.type="acs";
				o.errorServer="acs";
				o.ip=RoomModel.getRoomModel().goodsIp;
				o.port = RoomModel.getRoomModel().goodsProt;
				Log.out("连接ACS计费服务器失败或者断开");
				//RoomModel.getRoomModel().socketClose();
				sendToJsObj(o);
			}
		}
		
		
		//登陆计费
		private function _62():void {
			Log.out("登录ACS服务器")
			whandle(write._62());
		}
		//请求用户装备
		private function _51():void {
			if (RoomModel.getRoomModel().myUserInfo.isLongUser) {
				return;
			}
			whandle(write._51());
		}
		
		
		
	}
}