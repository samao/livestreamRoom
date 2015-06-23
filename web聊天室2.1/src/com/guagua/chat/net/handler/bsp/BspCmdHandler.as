package com.guagua.chat.net.handler.bsp
{
	//import com.adobe.serialization.json.JSON;
	import com.guagua.chat.model.ResNode;
	import com.guagua.chat.model.ResTree;
	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.HandlerMap;
	import com.guagua.chat.net.socket.CmdSocketHandel;
	import com.guagua.chat.util.GuaguaCipher;
	import com.guagua.chat.util.Operation;
	import com.guagua.chat.util.RC6;
	import com.guagua.net.RtmpStream;
	import com.guagua.utils.ConstVal;
	import flash.utils.Dictionary;
	
	import flash.events.TimerEvent;
	import flash.external.*;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	//import flash.utils.Timer;
	
	import flash.utils.Timer;

	/**
	 *
	 * @author Wen
	 */
	public class BspCmdHandler extends CmdSocketHandel
	{
		private var write:BspWriteDate;
		private var timer:Timer;
		public var bspIsR:Boolean = false;//Bsp是否返回数据		
		
		private var starInforBackCall:Function;
		
		public var _8000Ok:Boolean = false;
		
		/**断开连接以后的缓存请求队列*/
		private var cmdVector:Vector.<Object> = new Vector.<Object>();
		
		private var callBackDic:Dictionary = new Dictionary(true);
		
		public function BspCmdHandler(cmd:String)
		{
			super(cmd);	
			
			eType = 0;
			write = new BspWriteDate();			
					
			
			this.cmds = [6002];
			timer = new Timer(5000);
			timer.addEventListener(TimerEvent.TIMER, tComplete);
			
			this.resetKey();
			RC6.getInstance().rc6_set_key(keyBty,"BSP");
			
			write.keyBty=keyBty;
			write.eType=eType;				
			
			RoomModel.getRoomModel().bspAPI = this;
		}
		//socket关闭成功
		override public function socketCloseComplete():void{
			var o:Object = new Object();
			o.t = 10005;
			o.type="bsp";
			o.errorServer="bsp";
			o.ip=RoomModel.getRoomModel().bspIp;
			o.port = RoomModel.getRoomModel().bspProt;
			
			try {
				ExternalInterface.call("onData(" + JSON.stringify(o) + ")");
			}catch (e:Error) {
				trace("未定义js函数", "onData");
			}
					
			//ExternalInterface.call("onData(" + JSON.stringify(o) + ")");
		}
		//初始化
		override public function socketConnComplete():void {
			//this.whandle(this.write._8000(0));
			
			//this.wcmd(6003);
									
			if (bspIsR) {
				clearCmdVector();
				return;
			}
			timer.reset();
			timer.start();
		}
		
		private function clearCmdVector():void 
		{
			
			if (cmdVector.length > 0) {
				var obj:Object = cmdVector.splice(0, 1)[0];
				//存入已经发送的数组，方便回调时候定位	
				
				this._6001(obj.dstId, obj.type, obj.backCall);
				clearCmdVector();
				return;
			}
			
			//this.socket.closeToDo("未有命令关闭执行");
		}
		
		/**发送心跳包*/
		public function alive():void
		{
			//trace("BSP也发心跳包")
			this.whandle(this.write._3508());
		}
		
		//如果没有返回数据，再去请求
		private function tComplete(e:TimerEvent):void {
			
			//this.whandle(this.write._3508());
			
			if(RoomModel.getRoomModel().isACS||RoomModel.getRoomModel().myUserModel.isGuest){						
				
				if (this.bspIsR) {
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, this.tComplete);
					
					return
				}					
			
				_6001(RoomModel.getRoomModel().myUserInfo.uid, 3);
				
			}			
			
		}		
		
		override public function resetKey():void{
			keyBty.length=0;
			keyBty.endian=Endian.LITTLE_ENDIAN;
			keyBty.writeMultiByte(RoomModel.getRoomModel().resKey,"GB2312");
		}
		
		//是否返回数据
		public function isAgainConnect():Boolean{
			return !bspIsR;
		}
		
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
			//Log.out("BSPHANDLE:",cmdId)
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
		
		/**
		 * 
		 * //明星信息结构
			struct STRU_STAR_INFO_V4
			{
			INT64 m_i64UserID; //明星ID
			INT64 m_i64JoinDate; //加入时间
			INT64 m_i64Points; //积分 
			long m_lStarLevel; //等级
			INT64 m_i64PointsFlower; //当天收到的鲜花数 积分
			INT64 m_i64PointsGift; //当天收到的礼物数 积分
			long m_lPointsFactor; //当天积分系数
			INT64 m_i64PointsFlowerfLimit;//当天鲜花数限制 积分
			INT64 m_i64PointsGiftLimit; //当天礼物数限制 积分
			INT64 m_i64CountFlower; //当天收到的鲜花数
			INT64 m_i64CountGift; //当天收到的礼物数
			INT64 m_i64CountFlowerLimit; //当天收到的鲜花数限制
			INT64 m_i64CountGiftLimit; //当天收到的礼物数限制
			INT64 m_i64TotalFlower; //总鲜花数
			INT64 m_i64TotalGift; //总礼物数
			long m_lExchangeLevel; //兑点等级(0~6) 0 为不是兑点明星
			INT64 m_i64BrokerUID; //签约经纪人ID,-1代表未签约
			INT64 m_i64BrokerDate; //签约经纪人时间
			WORD m_wNameLen; //称号长度
			char m_szLevelName[DEF_LEVEL_NAME_LEN+1]; //称号
			}

		 * 
		 * */	

		/**
		 * 明星信息返回
		 * @author idzeir modify:20130701
		 * 
		 * */
		private function _6002(body:ByteArray,type:int=6002):void{
			var obj:Object = { t:type };
			
			try {
				// 用户ID
				obj.uid=Operation.getOperation().readLong(body);
				// // 转发类型
				obj.m_byType = body.readByte();			
				// 转发数据长度
				obj.lContentLen=body.readInt();
				//用户ID
				obj.m_i64UserID = Operation.getOperation().readLong(body);
				
				if (obj.m_byType == 9) {	
					var m_oStarInfo:Object = new Object();
					obj.m_i64StarID = Operation.getOperation().readLong(body);				
					
					m_oStarInfo.m_i64UserID =Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64JoinDate =Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64Points = Operation.getOperation().readLong(body);
					
					m_oStarInfo.m_lStarLevel = body.readInt();
					m_oStarInfo.m_i64PointsFlower = Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64PointsGift = Operation.getOperation().readLong(body);
					m_oStarInfo.m_lPointsFactor = body.readInt();
					
					m_oStarInfo.m_i64PointsFlowerfLimit = Operation.getOperation().readLong(body);		
					m_oStarInfo.m_i64PointsGiftLimit = Operation.getOperation().readLong(body);
					
					m_oStarInfo.m_i64CountFlower = Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64CountGift = Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64CountFlowerLimit = Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64CountGiftLimit = Operation.getOperation().readLong(body);
					
					m_oStarInfo.m_i64TotalFlower = Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64TotalGift = Operation.getOperation().readLong(body);
					m_oStarInfo.m_lExchangeLevel = body.readInt();
					
					m_oStarInfo.m_i64BrokerUID = Operation.getOperation().readLong(body);
					m_oStarInfo.m_i64BrokerDate = Operation.getOperation().readLong(body);
					
					obj.m_oStarInfo = m_oStarInfo;
					
					var fun:Function = findBackFun(m_oStarInfo.m_i64UserID);				
					if (fun!=null) {
						fun(m_oStarInfo);					
					}
					
				}else if (obj.m_byType == 5) {
					//职业ID
					obj.m_lJobID=body.readInt();
					//礼物个数
					obj.m_i64Count=Operation.getOperation().readLong(body);
					//最大花篮数
					obj.m_i64SelfMaxCount = Operation.getOperation().readLong(body);
					
					Log.out("请求花篮数：", obj.m_i64Count, obj.m_i64SelfMaxCount);
					
					ConstVal.MAX_FLOWERS_LIMITED = obj.m_i64SelfMaxCount;
					
					ConstVal.FLOWERS =  obj.m_i64Count;
					//ConstVal.MAX_SEND_FLOWERS = 99;
					obj.m_i64Count = ConstVal.FLOWERS;				
					
					bspIsR = true;
					
					clearCmdVector();
				}
			}catch (e:Error) {
				Log.out(type, e.message);
				return;
			}
			
			sendToJsObj(obj);
			obj = null;
		}	
		
		
		/**
		 * 定位回调位置
		 * */
		private function findBackFun(uid:uint):Function
		{
			var fun:Function;
			
			for(var i:* in callBackDic)
			{
				//trace(i);
				if (i == uid)
				{
					fun = callBackDic[i];
					callBackDic[i]=null;
					break;
				}
			}
			return fun;
		}
		
		
		//请求花篮数
		public function _6001(dstId:Number = 0, type:Number = 3, backCall:Function = null):void {
			callBackDic[dstId] = backCall;			
			if (this._socket.connecting) {					
				whandle(write._6001(dstId, type));						
			}else {
				//连接断开
				cmdVector.push( { "dstId":dstId, "type":type, "backCall":backCall,"status":0 } );
				if (!this._socket.connecting) {
					this.socket.againConnect();
				}				
			}
			
		}
		//登陆
		private function _6003():void{
			whandle(write._6003());
		}		
		
	}
}