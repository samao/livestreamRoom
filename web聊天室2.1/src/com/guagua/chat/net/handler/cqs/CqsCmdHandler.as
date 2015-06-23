package com.guagua.chat.net.handler.cqs
{
	//import com.adobe.serialization.json.JSON;
	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.HandlerMap;
	import com.guagua.chat.net.socket.CmdSocketHandel;
	import com.guagua.chat.util.Operation;
	import flash.utils.Timer;
	
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	//import flash.utils.Timer;
	import flash.external.ExternalInterface
	
	public class CqsCmdHandler extends CmdSocketHandel
	{
		private var write:CqsWriteData;
		private var timer:Timer;
		private var closeTimer:Timer;
		private var _4008_0:Number=0;
		private var _4008_6:Number=0;
		private var _4008_10:Number=0;
		private var _4008_12:Number=0;
		public function CqsCmdHandler(cmd:String)
		{
			super(cmd);
			write = new CqsWriteData();
			this.cmds =[4010,4011,4016,4024];
			timer=new Timer(10000);
			timer.addEventListener(TimerEvent.TIMER,timerFun);
			
		}
		//连接成功
		override public function socketConnComplete():void {
			
			timer.reset();
			timer.start();
			_4026();			
		}
		override public function socketCloseComplete():void{
			var o:Object = new Object();
			o.t = 10005;
			o.type="cqs";
			o.errorServer="cqs";
			o.ip=RoomModel.getRoomModel().cqsIp;
			o.port = RoomModel.getRoomModel().cqsPort;
			Log.out("CQS房间服务器失败或者断开");
			//RoomModel.getRoomModel().socketClose();
			//sendToJsObj(o);
			timer.stop();
			//this.socket.closeToDo("cqs断开连接")
		}
		//10秒申请一次
		private function timerFun(e:TimerEvent):void{
			//Log.out("10秒请求世界礼物，超级礼物")
			_4008(0);
			_4008(10);
			//_4008(12);取消小喇叭请求	
			//timer.removeEventListener(TimerEvent.TIMER,timerFun);
		}
		
		override public function handle(body:ByteArray, type:int = 0):Boolean {
			if (type != 0) {				
				super.handle(body,type);	
			}
			
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			localHandlerMap.put(body, 3);			
			handleData();
			return true;
		}
		
		private function handleData():void {
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			if (!localHandlerMap.hasByte(3)) {				
				return
			}
			var body:ByteArray = localHandlerMap.getByte(3);
			var cmdId:int = body.readShort();	
			//Log.out("cqs包：", cmdId);
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
		 * 赠送礼物通知(超级) 
		 * @author idzeir modify:20130701 
		 * */ 
		private function _4010(body:ByteArray, type:Number = 4010):void {			
			var obj:Object = { t:type };				
			try {
				obj.roomID = body.readInt();
				obj.roomName = Operation.getOperation().readGB2312String(body);
				obj.uid = Operation.getOperation().readLong(body);
				obj.nickName = Operation.getOperation().readGB2312String(body);
				obj.recnUid = Operation.getOperation().readLong(body);
				obj.recvNickName = Operation.getOperation().readGB2312String(body);
				obj.goodsID = body.readInt();
				obj.baseGoodsID = body.readInt();
				obj.goodsCount = body.readInt();
				obj.sendTime = Operation.getOperation().readLong(body);
				//下次申请，带上
				obj.giftID = _4008_0 = body.readUnsignedInt();
				//在线状态
				body.readInt();
				//用户身份(装备)
				Operation.getOperation().readLong(body);
				//用户身份(装备)(备用)
				Operation.getOperation().readLong(body);
				//其他参数备用
				Operation.getOperation().readLong(body);
				
			}catch (error:Error) {
				Log.out(type, error.message);
				return
			}			
			Log.out("接收超级礼物：", JSON.stringify(obj));
			sendToJsObj(obj);
			
			obj = null;
		}
		
		/**
		 * 小喇叭4011   v1 版本
		 * @author idzeir modify:20130701
		 * */
		private function _4011(body:ByteArray, type:int = 4011):void {			
			var obj:Object = { t:type };	
			try {
				obj.bugleID = _4008_12 = body.readInt();//下次申请，带上		
				obj.uid = Operation.getOperation().readLong(body);//发送者uid
				obj.nickName = Operation.getOperation().readGB2312String(body);//发送者name
				obj.roomID = body.readInt();
				obj.bugleType = body.readUnsignedByte();//0小喇叭  1大喇叭
				obj.backPic = body.readUnsignedByte();//背景图片
				obj.scope = body.readUnsignedByte();
				obj.repeatTime = body.readUnsignedByte();
				obj.fontName = Operation.getOperation().readGB2312String(body);
				obj.fontSize = body.readUnsignedByte();
				obj.fontColor = body.readInt();
				obj.msgTxt = Operation.getOperation().readGB2312String(body);
			}catch (error:Error) {
				Log.out(type, error.message);
				return
			}				
			//sendToJsObj(obj);	
			
			obj = null;
		}
		
		/**
		 * 小喇叭  v2 版本
		 * @author idzeir modify:20130701
		 * */
		private function _4016(body:ByteArray, type:int = 4011):void {	
			var obj:Object = { t:type };
			try {
				//消息 id
				obj.bugleID = _4008_12 = Operation.getOperation().readLong(body);//下次申请，带上
				//用户ID
				obj.uid = Operation.getOperation().readLong(body);
				//用户名
				obj.nickName = Operation.getOperation().readGB2312String(body);
				//房间ID
				obj.roomID = body.readInt();
				//类型
				obj.bugleType = body.readByte();
				//背景图片
				obj.backPic = body.readByte();
				//范围
				obj.scope = body.readByte();
				//重复次数
				obj.repeatTimes = body.readByte();
				//字体名称
				obj.fontName = Operation.getOperation().readGB2312String(body);
				//字体大小
				obj.fontSize = body.readByte();
				//字体颜色
				obj.fontColor = body.readInt();
				//消息文字
				obj.msgTxt = Operation.getOperation().readGB2312String(body);	
			}catch (error:Error) {
				Log.out(type, error.message);
				return
			}				
			//sendToJsObj(obj);	
			
			obj = null;
		}
		/*
		long		m_lRoomID;											//房间id
		TCHAR	    m_szRoomName[DEF_ROOM_NAME_LEN + 1];				//房间名称
		
		BYTE		m_bySendStationID;									//发送者所在站点ID
		TCHAR		m_szSendStationName[DEF_STATION_NAME_LEN+1];        //发送都所在站点名称
		
		BYTE		m_bySendUserStationID;								//发送者所属小站ID
		TCHAR		m_szSendUserStationName[DEF_STATION_NAME_LEN+1];	//发送者属小站名称
		INT64		m_i64UserID;										//发送者用户ID
		TCHAR		m_szUserNickName[DEF_NICK_NAME_LEN+1];				//发送者昵称
		
		BYTE		m_byRecvUserStationID;								//接收者所属小站ID
		TCHAR		m_szRecvUserStationName[DEF_STATION_NAME_LEN+1];	//接收者所属小站名称
		INT64		m_i64RecvUserID;									//接收者用户ID
		TCHAR		m_szRecvUserNickName[DEF_NICK_NAME_LEN+1];			//接收者昵称
		
		long		m_lGoodsID;											//商品ID
		long		m_lBaseGoodsID;										//商品基本分类ID
		long		m_lGoodsCount;										//数量
		INT64		m_i64SendTime;										//发送时间
		
		INT64		m_i64WorldGiftID;									//礼物ID
		
		long		m_lActionProperty;									//动作特效属性
		TCHAR		m_szDescript[DEF_REASON_BUF_LEN+1];					//描述信息
		long		m_lOtherPara;										//其他参数
		long		m_lOemID;											//产品分类信息
        */
		
		/**
		 * 世界礼物
		 * @author idzeir modify:20130701
		 * */
		private function _4024(body:ByteArray,type:int=4024):void{
			var obj:Object = { t:type };
			try {			
				obj.m_lRoomID = body.readInt();
				obj.m_rName = Operation.getOperation().readGB2312String(body);
				
				obj.m_bySendStationID = body.readByte();
				obj.m_szSendStationName = Operation.getOperation().readGB2312String(body);
				
				obj.m_szSendStationName = body.readByte();
				obj.m_szSendUserStationName = Operation.getOperation().readGB2312String(body);
				obj.m_i64UserID = Operation.getOperation().readLong(body);
				obj.m_szUserNickName = Operation.getOperation().readGB2312String(body);
				
				obj.m_byRecvUserStationID = body.readByte();
				obj.m_szRecvUserStationName = Operation.getOperation().readGB2312String(body);
				obj.m_i64RecvUserID = Operation.getOperation().readLong(body);
				obj.m_szRecvUserNickName = Operation.getOperation().readGB2312String(body);
				
				obj.m_lGoodsID = body.readInt();
				obj.m_lBaseGoodsID = body.readInt();
				obj.m_lGoodsCount = body.readInt();
				obj.m_i64SendTime = Operation.getOperation().readLong(body);
				
				obj.m_i64WorldGiftID = Operation.getOperation().readLong(body);
				
				obj.m_lActionProperty = body.readInt();
				obj.m_szDescript = Operation.getOperation().readGB2312String(body);
				obj.m_lOtherPara = body.readInt();
				obj.m_lOemID = body.readInt();
				
				_4008_10 = obj.m_lGoodsID;
			}catch (error:Error) {
				Log.out(type, error.message);
				return
			}	
			Log.out("世界礼物：",JSON.stringify(obj));
			sendToJsObj(obj);	
			
			obj = null;			
		}
		
		//登陆
		private function _4026():void {
			Log.out("登录cqs服务器")
			whandle(write._4026());
		}
		//请求小喇叭，超级礼物
		private function _4008(type:int=0):void{
			whandle(write._4008(type,this["_4008_"+type]));
		}
	}
}