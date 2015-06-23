package com.guagua.chat.net.handler.room
{
	import com.guagua.chat.model.ResTree;
	import com.guagua.events.EventProxy;
	import com.guagua.events.FmsEvent;
	import com.guagua.events.RoomEvent;
	import com.guagua.chat.model.FmsManager;
	import com.guagua.chat.model.FmsModel;
	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.HandlerMap;
	import com.guagua.chat.net.socket.CmdSocketHandel;
	import com.guagua.chat.net.socket.SocketManager;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import flash.sampler.NewObjectSample;
	//import com.guagua.chat.util.GuaguaCipher;
	import com.guagua.chat.util.Operation;
	import com.guagua.chat.util.RC6;
	import com.guagua.utils.ConstVal;
	
	import flash.events.TimerEvent;
	import flash.external.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	

	/**
	 * ...解包
	 * @author Wen
	 */
	public class RoomCmdHandler extends CmdSocketHandel
	{
		//返回C结构体Bty
		public var write:RoomWriteData;
		//定时器
		private var timer:Timer;
		//关闭后重新连接检查
		private var closeTimer:Timer;
		//登录失败后
		/**判断是否已经登录返回**/
		public var is1002:Boolean = false;		
		
		public var is1009:Boolean = false;
		
		private var isSendWebData:Boolean = false;		
		
		private var micDic:Dictionary = new Dictionary();
		
		private var frameIndex:uint = 0;
		
		private var _1038_OK:Boolean = false;
		
		/**缓存数据包*/
		private var byteVec:Vector.<Object> = new Vector.<Object>();
		
		public function RoomCmdHandler(cmd:String) 
		{
			super(cmd);
			eType=1;
			write = new RoomWriteData();
			this.cmds = [1002, 1005, 1006, 1007, 1009, 1011, 1013, 1015, 1016, 1023, 1024, 1025, 1026, 1028, 1029, 1030, 1031, 1033, 1038, 1040, 1046, 1047, 1049, 1052, 1053, 1057, 1063, 4010, 4011, 7203, 7204, 8004];
			
			if(ExternalInterface.available){
				//聊天
				ExternalInterface.addCallback("Client_To_Server_message", Client_To_Server_message);
				//送礼物
				ExternalInterface.addCallback("Song_li_Wu", Song_li_Wu);
				//对其他用户操作
				ExternalInterface.addCallback("OperateOtherUser", OperateOtherUser);
				//ExternalInterface.addCallback("RoomOperateOtherUser", RoomOperateOtherUser);
				//发送小喇叭
				//ExternalInterface.addCallback("smallSpeake", _1048);
				//房间管理 
				//ExternalInterface.addCallback("roomAdministration",_1032);
				//发送语音id
				//ExternalInterface.addCallback("sendAVId",write_1026);
				//申请资源 排麦
				//ExternalInterface.addCallback("applicationResources",_1027);
				//全战广播
				//ExternalInterface.addCallback("_1051", _1051);
				
				ExternalInterface.addCallback("isForbidSpeark", isForbidSpeark);
			}
			//RC6.getInstance().
			RC6.getInstance().rc6_set_key(keyBty);
			write.keyBty=keyBty;
			write.eType=eType;
			init();		
			
			RoomModel.getRoomModel().casAPI = this;
		}
		
		public function isForbidSpeark(uid:Number=0):Boolean {				
			return Boolean(RoomModel.getRoomModel().isForbidSpeark);
		}
		
		//socket连接成功
		override public function socketConnComplete():void{
			//trace(RoomModel.getRoomModel().myRoomInfo.loginType);
			var o:Object = new Object();
			o.t = 10003;
			sendToJsObj(o);			
			whandle(this.write._1039());			
			
			//10秒内没有登录包回来重新连接
			var timeOutFun:Function = function():void
			{				
				if (!is1002)
				{
					Log.out("10秒内没有登录包回来重新连接");					
					//ErrorToServerMgr.getLocal().add( { errorID:104, serverIp:RoomModel.getRoomModel().roomProxyIp, serverPort:RoomModel.getRoomModel().roomProxyPort} );
					EventProxy.instance().dispatchEvent(new RoomEvent(RoomEvent.Event_Socket_Cas_Ip_Err));
				}
			}
			
			setTimeout(timeOutFun, 10000);			
		}
		
		//socket关闭成功
		override public function socketCloseComplete():void{
			errorHandler();
		}
				
		override public function handle(body:ByteArray, type:int = 0):Boolean {
			if (type != 0) {				
				super.handle(body,type);	
			}
			
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			localHandlerMap.put(body, 0);			
			handleData();
			return true;
		}
		
		private function handleData():void {
			var localHandlerMap:HandlerMap = HandlerMap.getMap();
			if (!localHandlerMap.hasByte(0)) {				
				return
			}
			var body:ByteArray = localHandlerMap.getByte(0);
			var cmdId:int = body.readShort();	
			//if(cmdId!=1035&&cmdId!=1031)trace(this.cmds.indexOf(cmdId)>=0?"有包":"无包",cmdId,"cas")
			if (cmds.indexOf(cmdId) >= 0) {				
				try {
					//跳过必须数据包
					if (ResTree.isReady&&byteVec.length==0||!is1002||!is1009||cmdId==1031) {
						this["_"+cmdId](body);
					}else {
						//缓存数据
						byteVec.push( { cmdId:cmdId, data:body } );
					}
					
				}catch (e:Error) {					
					var obj:Object = new Object();
					obj.t = 1007;
					//obj.roomID = roomID;
					obj.uid = 0;
					obj.nickName="调试";
					obj.dstUid = 0;
					obj.dsName="调试";
					obj.txtMsg =cmdId+""+ e.message;					
					sendToJsObj(obj);
				}
				
			}
			handleData();
		}
		
		/**
		 * res明星资源下载完成以后，处理缓存数据
		 * */
		public function dealVec():void
		{
			//Log.out("处理缓存的数据：", byteVec.length);
			if (byteVec.length)
			{
				var obj:Object = byteVec.splice(0, 1)[0];
				this["_" + obj.cmdId](obj.data);
				dealVec();
			}
		}
		
		//发包
		override public function wcmd(cmd:int):void {
			this["_" + cmd]();
			return;
		}
		//回收
		override public function gc():void{
			super.gc();
			if(timer!=null){
				timer.reset();
				timer=null;
			}
		}
		/**
		 * 登陆cas成功
		 */
		private function loginOkDispatch():void {
			startToSend();
			var e:RoomEvent=new RoomEvent(RoomEvent.Event_Socket_Cas_Login);
			e.data=true;//登陆结果
			EventProxy.instance().dispatchEvent(e);
			//this.socket.dispathEvent(new RoomEvent(RoomEvent.Event_Socket_Cas_Login));
		}
		//初始
		private function init():void {
			var o:Object = new Object();
			o.t = 10004;
			sendToJsObj(o);
		}
		//断开
		private function errorHandler():void {				
			//如果登录没返回就断开说明服务器连接不上,否则密码错误不处理,1002消息自己忘web发包
			if(!is1002){
				/*if(closeTimer==null){
					closeTimer = new Timer(5000,1);
					closeTimer.addEventListener(TimerEvent.TIMER, closeTimerFun);
				}
				closeTimer.reset();
				closeTimer.start();	*/				
				return
			}else{//重新连接
				//_socket.againConnect();
				if(loginInfo!="登录成功")return
				RoomModel.getRoomModel().socketClose();
				
				if (RoomModel.getRoomModel().myRoomInfo.IsRoomClose==1)
				{
					//关闭
					Log.out("房间关闭\n\n\n\n\n\n\n\n\n\n.\n\n\n\n.\n\n\n\n.")
					RoomModel.getRoomModel().iPlayer.delAllMicUser();
				}else {					
					EventProxy.instance().dispatchEvent(new RoomEvent(RoomEvent.Event_Socket_Cas_Ip_Err));
				}
			}
			Log.out("roomProxy 断开了连接：", is1002, loginInfo, RoomModel.getRoomModel().myRoomInfo.IsRoomClose);
		}
		//断开重连 定时
		private function closeTimerFun(e:TimerEvent):void {
			var o:Object = new Object();
			o.t = 10005;
			o.type="cas";
			o.errorServer="cas";
			o.ip=RoomModel.getRoomModel().roomProxyIp;
			o.port = RoomModel.getRoomModel().roomProxyPort;
			
			RoomModel.getRoomModel().socketClose();
			sendToJsObj(o);
			if (RoomModel.getRoomModel().myRoomInfo.IsRoomClose!=0) {
				//_socket.againConnect();
				//_socket.connectServer("121.17.125.46",9318);
			}
		}
		
		
		public function logOut():void
		{
			whandle(write._1018());
		}
		
		
		//定时器启动
		private function startToSend():void {
			//trace("RoomCmdHandler startToSend-----------------------");
			//return;
			if (timer == null) {
				timer = new Timer(5000);
				timer.addEventListener(TimerEvent.TIMER, timerFun);
			}
			
			whandle(write._1003(0));
			whandle(write._1003(1));
			whandle(write._1003(2));
			//whandle(write.GetWRsFrame());
			timer.reset();
			timer.start();
		}
		
		//private var someOk:Boolean = false;
		private function timerFun(e:TimerEvent):void {
			if (!_socket.connecting) {
				RoomModel.getRoomModel().myRoomInfo.isLoginRoom = 0;
				timer.reset();
				return;
			}			
			
			//如果用户列表没下来，继续申请
			if (timer.currentCount % 6 == 0 && _socket.connecting) {
					if (!(this._1024_OK && this._1025_OK && RoomModel.getRoomModel().myRoomInfo.isLoginRoom==1)) {
						whandle(write._1003(1));
					}else {
					}
					if (!_1038_OK && RoomModel.getRoomModel().myRoomInfo.isLoginRoom==1) {
						whandle(write._1003(0));
					}
			}
			//给麦上用户找名字
			if(timer.currentCount%2){
				getMicUserName();//麦上用户名字
				getMicXName();//麦序名字
			}
			//心跳
			if (_socket.connecting) whandle(write._1035());
			if (RoomModel.getRoomModel().bspAPI.socket.connecting) RoomModel.getRoomModel().bspAPI.alive();
			
			//一分钟获取鲜花
			if (timer.currentCount % 4 == 0) {
				//Log.out("&&",ConstVal.FLOWERS,ConstVal.MAX_FLOWERS_LIMITED)
				if (RoomModel.getRoomModel().myUserModel.uid<RoomModel.getRoomModel().maxUid) {
					//Log.out("我一分钟获取鲜花",RoomModel.getRoomModel().myUserInfo.uid)
					OperateOtherUser(RoomModel.getRoomModel().myUserInfo.uid,17,1);
				}				
			}
			
			//第一次分页列表
			
			if (!isSendWebData && _1038_OK) {
				isSendWebData = true;
				sendWebData();
				return;
			}			
			
			if (isSendWebData) {				
				if (timer.currentCount % 4 == 0) {
					//Log.out("缓存：", timer.currentCount);
					sendWebData();
				}
			}
		}
		
		private function sendWebData(arg:Number=1):void {
			if (RoomModel.getRoomModel().isSending) {
				return;
			}
			RoomModel.getRoomModel().isSending = true;
			var sendobj:Object = new Object();
			sendobj.t = 1038;
			sendobj.roomID = RoomModel.getRoomModel().thisRoomID;
			sendobj.userList = RoomModel.getRoomModel().getUserList(arg);
			sendobj.userCount =RoomModel.getRoomModel().userList.length;
				
				
			sendobj.userCount=RoomModel.getRoomModel().totalUser;
			sendobj.adminUserCount=RoomModel.getRoomModel().totalAdUser;
			sendobj.micUserCount=RoomModel.getRoomModel().totalMicUser;				
				
			//Log.out("推数据：", sendobj.userCount);
			sendToJsObj(sendobj);
			
			RoomModel.getRoomModel().deailCache();
		}
		
		/*******************************************************************************************
		 *解读
		 *******************************************************************************************/
		//注册用户登陆应答
		private function _1002(body:ByteArray,type:int=1002):void {
			is1002=true;
			//trace("登陆应答 1002");
			
			var obj:Object = new Object();
			obj.t = 1002;
			//用户ID
			obj.m_i64UserID = Operation.getOperation().readLong(body);
			
			RoomModel.getRoomModel().myUserInfo.isLongUser=(obj.m_i64UserID>=RoomModel.getRoomModel().maxUid)
			
			//房间ID
			obj.m_lRoomID = body.readInt(); 	
			//1是同意其它是拒绝，0
			RoomModel.getRoomModel().myRoomInfo.isLoginRoom=obj.m_byLoginResult = body.readByte(); 
			//错误消息
			loginInfo = obj.m_szErrInfo = Operation.getOperation().readGB2312String(body); 
			//会话密钥
			obj.m_lSessionKey=RoomModel.getRoomModel().key=body.readInt(); 
			
			//密钥
			keyBty.length=0;
			var len:Number=body.readShort();
			keyBty.writeBytes(body,body.position,len);
			body.position=body.position+len;
			
			//RoomModel.getRoomModel().ekey=Operation.getOperation().readGB2312String(body);
		
			//房间最大人数
			obj.m_wRoomMaxUser = body.readShort(); 
			//房间属�?From DataBase
			obj.m_lRoomProperty = body.readInt(); 
			
			//房间状�?Dynamic Data
			RoomModel.getRoomModel().myRoomInfo.roomState=obj.m_lRoomState = body.readInt(); 
			obj.m_2lRoomState = obj.m_lRoomState.toString(2);
			
			RoomModel.getRoomModel().myRoomInfo.m_lRoomState = obj.m_lRoomState;			
			
			RoomModel.getRoomModel().myRoomInfo.m_lRoomProperty = obj.m_lRoomProperty;
			
			//trace("==========================================="+obj.m_lRoomState);
			//本人的NAT地址
			obj.m_lNatIpAddr = body.readInt(); 
			 //麦的数量
			obj.m_byMicCount = body.readByte();
			//视频数量
			obj.m_byVideoCount = body.readByte(); 
				//trace(obj.m_byVideoCount);
			obj.m_szMcsAddr = Operation.getOperation().readGB2312String(body); 
			
			//服务器端�?
			obj.m_wMcsPort=body.readUnsignedShort(); 
			// 房主ID
			obj.m_i64MOPID = Operation.getOperation().readLong(body); 
			//登录CMS校验码长�?2个字�?
			obj.m_szVerifyKey = Operation.getOperation().readGB2312String(body);  
			
			Log.out("CMS:", obj.m_szMcsAddr + ":" + obj.m_wMcsPort, obj.m_lRoomState.toString(2));			
			obj.allowedCheers = obj.m_lRoomState >> 5 & 1;			
			
			if (obj.m_byLoginResult == 1){					
				loginOkDispatch();
				RoomModel.getRoomModel().myUserInfo.isLogin=1;				
			}else{
				this.resetKey();
				trace("连接失败：", socket.connecting);
			}
			
			if(obj.m_byLoginResult==1&&obj.m_szErrInfo=="登陆成功"){
				var fmsNode:FmsModel=new FmsModel(obj.m_lRoomID,obj.m_szMcsAddr,obj.m_wMcsPort)
				FmsManager.getInstance().addFms(fmsNode);
				FmsManager.getInstance().dispatchEvent(new FmsEvent(FmsEvent.FMS_READY));
				FmsManager.getInstance().dispatchEvent(new FmsEvent(FmsEvent.FMS_RECEIVE));					
			}
			
			//ErrorToServerMgr.getLocal().addCountStr( "cas:" + RoomModel.getRoomModel().roomProxyIp + ":" + RoomModel.getRoomModel().roomProxyPort + "|" + ConstVal.date );
			Log.out("登录CAS结果："+RoomModel.getRoomModel().roomProxyIp,RoomModel.getRoomModel().roomProxyPort,RoomModel.getRoomModel().m_byIspType,obj.m_szErrInfo)
			sendToJsObj(obj);	
			
			//进度条控制
			if (ExternalInterface.available&&!ConstVal.videoEnabled) 
			{
				if (obj.m_byLoginResult == 1)
				{
					ExternalInterface.call("updateProgess",false);
				}else {
					ConstVal.videoEnabled = true;
					ExternalInterface.call("updateProgess",true);
				}
			}
		}
		
		/*类型
			data.writeShort(cmd);
			//long m_lRoomID;       //房间ID
			data.writeInt(room.m_szRoomId);
			//来源用户ID
			bty = Operation.getOperation().long2Bytes(user.uid, true);
			data.writeBytes(bty, 0, 8);
			//会话密钥
			data.writeInt(RoomModel.getRoomModel().key);
			//请求的数据类型
			data.writeShort(type);
			//备用参数
			bty.length = 0;
			bty = Operation.getOperation().long2Bytes(232323, true);
			data.writeBytes(bty, 0, 8);*/
		private function _1031(body:ByteArray,type:int=1031):void{
			//trace("Fms服务器地址应答")			
			var roomid:Number=(body.readInt());
			body.readInt();
			var len:uint=body.readShort()
			for(var i:uint=0;i<len;i++){
				body.readShort();
				body.readInt();
				body.readByte();
				body.readByte();
				var ip:String=Operation.getOperation().readGB2312String(body)
				var port:Number=body.readUnsignedShort();
				FmsManager.getInstance().addFms(new FmsModel(roomid,ip,port));
				//trace("1031:"+ip+":"+port)				
			}
			//DebugPanel.Log("FMS列表请求成功")
			Log.out(FmsManager.getInstance().toString())	
			FmsManager.getInstance().dispatchEvent(new FmsEvent(FmsEvent.FMS_RECEIVE));
		}
		
		/*
		// 媒体服务器信息通知包
		struct STRU_CL_CAS_CMS_INFO_ID
		{
		long    m_lRoomID;                              // 房间ID
		
		BYTE    m_byMicType;                            // 麦类型   ENUM_MIC_TYPE
		short   m_sMicIndex;                            // 麦序号
		
		char	m_szCmsAddr[DEF_IP_ADDR_LEN + 1];       // 媒体服务器地址
		WORD	m_wCmsPort;                             // 媒体服务器端口
 
		
		*/
		
		private function _1057(body:ByteArray,type:int=1057):void{
			var obj:Object=new Object();
			try{
				obj.t=type;
				obj.m_lRoomID = body.readInt();
				obj.m_byMicType=body.readByte();
				obj.m_sMicIndex=body.readShort();
				obj.m_szCmsAddr=Operation.getOperation().readGB2312String(body);
				obj.m_wCmsPort = body.readUnsignedShort();	
				
				FmsManager.getInstance().addFms(new FmsModel(obj.m_lRoomID, obj.m_szCmsAddr, obj.m_wCmsPort));
			}catch(e:Error){
				trace(e.message);
			}
			
			Log.out("_1057",JSON.stringify(obj))
			
			//sendToJsObj(obj)
		}
		
		//游客登陆WBS应答 8004
		private function _8004(body:ByteArray, type:int = 1002):void {
			//trace("登陆应答 8004");
			var obj:Object = new Object();
			obj.t = 1002;
			obj.uid = Operation.getOperation().readLong(body);//uid
			//1是同�?其它是拒�?
			RoomModel.getRoomModel().myRoomInfo.isLoginRoom = obj.m_byLoginResult = body.readByte(); 
			//trace(IsLongin);
			body.readInt();//roomid
			//错误消息
			obj.m_szErrInfo = Operation.getOperation().readGB2312String(body); 
			//trace(LoginMessage);
			RoomModel.getRoomModel().key= body.readInt(); //会话
			if (RoomModel.getRoomModel().key == 49) RoomModel.getRoomModel().myRoomInfo.IsRoomClose = RoomModel.getRoomModel().key;
			//sendToJsObj(obj);
			//Many_Data(8004);
			//trace("游客登陆: 结果:"+obj.m_byLoginResult);
			if (obj.m_byLoginResult == 1) {
				RoomModel.getRoomModel().myUserInfo.isLogin=1;
				whandle(write.GetWRsFrame());
				startToSend();
			}
		}
		
		/**新用户列表包*/
		private function _1040(body:ByteArray,type:int=1040):void {				
			var roomID:int = body.readInt();
			var userCount:int = body.readShort();
			
			for (var i:uint = 0; i < userCount; i++) {
				//__001++;
				var userMode:UserInfo=new UserInfo();
				userMode.uid=Operation.getOperation().readLong(body);
				userMode.name=Operation.getOperation().readGB2312String(body);
				userMode.m_wPhotoNum=body.readShort();
				userMode.m_byUserRule=body.readUnsignedByte();
				userMode.m_userState= body.readInt();
				userMode.m_i64EquipState=Operation.getOperation().readLong(body);//body.readDouble();	
				userMode.m_wTuyaImage=body.readShort();
				userMode.m_i64EquipState2 = Operation.getOperation().readLong(body);
				//userMode.sortIndex = Operation.getOperation().calculationSortNum(userMode.uid, userMode.m_byUserRule, userMode.m_i64EquipState, userMode.m_i64EquipState2);
				
				if(ConstVal.isRebroader(userMode.uid)||(userMode.m_userState>>7&1)||RoomModel.getRoomModel().isLeave(userMode.uid)){
					continue 
				}
				RoomModel.getRoomModel().addUserModel(userMode);				
			}
			//Log.out("_1040", userCount,RoomModel.getRoomModel().totalUser);
			_1038_OK = true;	
		}			
		
		//当前所有麦上用户1025
		private var _1025_OK:Boolean = false;
		private function _1025(body:ByteArray, type:int = 1025):void {
			if (_1025_OK)
			{
				return;
			}
			
			//Log.out("当前所有麦用户1025" );
			var micList:Array = new Array();
			var micCount:int = body.readShort();
			for (var i:uint = 0; i < micCount; i++){
				var micIndex:Number = body.readShort();
				var micState:Number = body.readInt();
				var managerID:Number = Operation.getOperation().readLong(body);
				var micTime:Number = body.readShort();
				var speakUserID:Number = Operation.getOperation().readLong(body);
				var stopSpeakTime:Number = body.readInt();
				var startTime:Number  = body.readInt();
				
				micDic["mic" + micIndex] = RoomModel.getRoomModel().getUser(speakUserID);
				micList.push(RoomModel.getRoomModel().addMicUserModel(micIndex,micState,managerID,micTime,speakUserID,stopSpeakTime,startTime).getJsObj());
			}				
			
			var mictype:int = body.readByte();
			var sendobj:Object = new Object();
			sendobj.t = type;
			sendobj.svrID = mictype;
			sendobj.sessionKey = 0;
			sendobj.micCount = micCount;
			sendobj.micList = micList;
			//sendToJsObj(sendobj);
			
			videoInitCheck()
			_1025_OK = true;			
			
		}
		
		
		private function videoInitCheck():void {	
			
			Mictimer=new Timer(200);
			Mictimer.addEventListener(TimerEvent.TIMER,checkHandler)
			Mictimer.start();
		}
		
		protected function checkHandler(event:TimerEvent):void
		{
			//bsp数据完成
			if (RoomModel.getRoomModel().bspAPI == null) {
				//return;
			}
			
			//cas数据完成
			if (ConstVal.BITMAPDATA==null||!is1009||!is1002) {
				return;
			}
			
			/*RoomModel.getRoomModel().videoStyleIndex = frameIndex;
			RoomModel.getRoomModel().iPlayer.videoStyle(frameIndex);*/
			
			for (var i:uint = 0; i < 3; i++) {
				if (micDic["mic" + i] != null&&micDic["mic" + i].uid!=0) {
					//麦上有人
					RoomModel.getRoomModel().iPlayer.addMicUser(micDic["mic" + i], i);
				}else {
					RoomModel.getRoomModel().iPlayer.delMicUser(null, i);
				}
			}
			//Log.out("买包回来--------------------------",i)
			Mictimer.stop();
			Mictimer.removeEventListener(TimerEvent.TIMER, checkHandler);
		}		
		
       //麦上用户  游客服务器返回
		private function _7203(body:ByteArray,type:int=1025):void {
			var micList:Array=new Array();
			trace("WBS房间所有麦上用 7203");
			var svrID:int=body.readInt();
			var sessionKey:int=body.readInt();
			var micCount:int=body.readInt();
			for (var i:uint=0; i < micCount; i++)
			{
				var micIndex:Number = body.readShort();
				var micState:Number = body.readInt();
				var managerID:Number = Operation.getOperation().readLong(body);
				var micTime:Number = body.readShort();
				var speakUserID:Number = Operation.getOperation().readLong(body);
				var stopSpeakTime:Number = Operation.getOperation().readLong(body);
				var startTime:Number  = Operation.getOperation().readLong(body);
				micList.push(RoomModel.getRoomModel().addMicUserModel(micIndex,micState,managerID,micTime,speakUserID,stopSpeakTime,startTime).getJsObj());
			}
			_1025_OK = true;
			var sendobj:Object = new Object();
			sendobj.t = 1025;
			sendobj.svrID = svrID;
			sendobj.sessionKey = sessionKey;
			sendobj.micCount = micCount;
			sendobj.micList = micList;
			//sendToJsObj(sendobj);			
		}
		//麦上用户  游客服务器返回
		private function _7204(body:ByteArray,type:int=1025):void {
			trace("WBS房间所有麦上用 7204");
			var obj:Object = new Object();
			var svrID:int = body.readInt();
			var sessionKey:int = body.readInt();
			/*obj.micIndex = body.readShort();
			obj.micState= body.readInt();
			obj.managerID= Operation.getOperation().readLong(body);
			obj.micTime = body.readShort();
			obj.speakUserID= Operation.getOperation().readLong(body);
			obj.stopSpeakTime= Operation.getOperation().readLong(body);
			obj.startTime = Operation.getOperation().readLong(body);*/
			
			var micIndex:Number = body.readShort();
			var micState:Number = body.readInt();
			var managerID:Number = Operation.getOperation().readLong(body);
			var micTime:Number = body.readShort();
			var speakUserID:Number = Operation.getOperation().readLong(body);
			var stopSpeakTime:Number = Operation.getOperation().readLong(body);
			var startTime:Number  = Operation.getOperation().readLong(body);

			_1025_OK = true;
			var sendobj:Object = new Object();
			sendobj.t = 1025;
			sendobj.svrID = svrID;
			sendobj.sessionKey = sessionKey;
			sendobj.micCount = 3;
			
			sendobj.micList = [RoomModel.getRoomModel().addMicUserModel(micIndex,micState,managerID,micTime,speakUserID,stopSpeakTime,startTime).getJsObj()];
			//sendToJsObj(sendobj);
		}
		//由于用户列表分批下载,补充麦上用户名称
		private function getMicUserName():void{
			/*var ary:Array=RoomModel.getRoomModel().micUserFindName();
			if(ary.length>0){
				var sendobj:Object = new Object();
				sendobj.t = 1025;
				sendobj.svrID = 0;
				sendobj.sessionKey = 0;
				sendobj.micCount = ary.length;
				sendobj.micList=ary;
				//sendToJsObj(sendobj);
				
			}*/
		}
		//麦序1024
		private var _1024_OK:Boolean = false;
		private var Mictimer:Timer;
		private var loginInfo:String;
		private function _1024(body:ByteArray,type:int=1024):void {
			//trace("+++++++++++++++++++++++++++++++++++麦序:" + type);
			var micList:Array = new Array();
			RoomModel.getRoomModel().micXNameIsOk=false;
			RoomModel.getRoomModel().micXUserIDList=[];
			var micCount:int = body.readUnsignedByte();
			//trace(micCount);
			for (var i:uint = 0; i < micCount; i++){
				var obj:Object = new Object();
				obj.uid  = Operation.getOperation().readLong(body);
				RoomModel.getRoomModel().micXUserIDList.push(obj.uid);
				
				micList.push(JSON.stringify(obj));
			}
			_1024_OK = true;
			var sendobj:Object = new Object();
			sendobj.t = type;
			sendobj.micCount = micCount;
			sendobj.micList = micList;
			
			sendobj.micCount=RoomModel.getRoomModel().totalMicUser;
			if(micCount==0){
				RoomModel.getRoomModel().micXNameIsOk=true;
				//sendToJsObj(sendobj);
			}
			//m_proces_server.ProcessMicOrder(type, micCount, micList);
		}
		//返回麦上用户名
		public function getMicXName():void{
			if(RoomModel.getRoomModel().micXUserIDList.length==0)return;
			var micList:Array =[];
			RoomModel.getRoomModel().micXNameIsOk=true;
			for(var i:int=0;i<RoomModel.getRoomModel().micXUserIDList.length;i++){
				var user:UserInfo=RoomModel.getRoomModel().getUser(RoomModel.getRoomModel().micXUserIDList[i]);
				if(user==null){
					RoomModel.getRoomModel().micXNameIsOk=false;
				}else{
					micList.push(JSON.stringify(user.getJsObj()));
					//trace(user.name)
				}
				
			}
			var sendobj:Object = new Object();
			sendobj.t = 1024;
			sendobj.micCount = micList.length;
			sendobj.micList = micList;
			sendToJsObj(sendobj);
		}
		
		
		//媒体配置信息1009
		private function _1009(body:ByteArray,type:int=1009):void {
			
			body.readInt();//房间ID
			//语音参数 STRU_AUDIO_CONFIG_INFO
			body.readByte();//编码类型
			body.readInt();// //采样频率 DWORD
			body.readShort();//通道�?
			body.readShort();//采样宽度
			body.readShort();//带宽
			body.readShort();//每包数据长度
			
			var video_num:int = body.readByte();////视频类型个数
			var Frame_ary:Array = new Array();
			
			
			ConstVal.frameVec = new Vector.<uint>();
			
			var videoHeightArr:Array = [];
			//视频参数STRU_VIDEO_CONFIG_INFO
			for (var i:int = 0; i < video_num; i++) {
				var obj:Object = new Object();
				obj.m_byCodeType=body.readByte();//编码类型
				obj.m_sFrameWidth=body.readShort();
				obj.m_sFrameHeight=body.readShort();
				obj.m_sColorSpace=body.readShort(); 
				obj.m_sFramesPerSec = body.readShort();//每秒几帧
				ConstVal.frameVec.push(obj.m_sFramesPerSec);
				videoHeightArr.push(obj.m_sFrameHeight)
				//Log.out("视频配置：", JSON.stringify(obj));
				//if (obj.m_sFramesPerSec < 5) obj.m_sFramesPerSec = 5;
				
				obj.m_byVideoQuality=body.readByte();//视频质量
				Frame_ary.push(JSON.stringify(obj));
				Log.out("视频配置：", JSON.stringify(obj));
			}
			//Log.out("1009 媒体配置信息:", "视频类型数量", video_num,"视频帧率：",ConstVal.frameVec);
			body.readByte();	 //麦类�?
	
			var sendobj:Object = new Object();
			sendobj.t = type;
			sendobj.frameary = Frame_ary;
			//sendToJsObj(sendobj);
			//m_proces_server.ProcessMedia(type,Frame_ary,micTotal);
			
			if (videoHeightArr[0] > (videoHeightArr[1] + videoHeightArr[2])) {
				RoomModel.getRoomModel().videoStyleIndex = frameIndex = 1;				
				RoomModel.getRoomModel().iPlayer.videoStyle(1);
			}else {
				RoomModel.getRoomModel().videoStyleIndex = frameIndex = 2;
				RoomModel.getRoomModel().iPlayer.videoStyle(2);
			}
			
			is1009 = true;
		}
		//新用户进�?005
		private function _1005(body:ByteArray, type:int = 1005):void {
			try{
				//trace("+++++++++++++++++++++++++++++新用户进" + type);
				var roomId:int = body.readInt();
				//trace("===" + roomId);
				var uid:Number = Operation.getOperation().readLong(body);
				//trace("===" + uid);
				var nickName:String = Operation.getOperation().readGB2312String(body);
				//trace("===" + nickName);
				var photoNum:int = body.readShort();
				var userRule:int = body.readUnsignedByte();
				var userState:int = body.readInt();
				var equipState:Number = Operation.getOperation().readLong(body);
				//var tuyaImg:int = body.readShort();
				var comeinTip:String = Operation.getOperation().readGB2312String(body);
				
				var equipstate2:Number = Operation.getOperation().readLong(body);
				//var sortIndex:Number = Operation.getOperation().calculationSortNum(uid, userRule, equipState,equipstate2);
				
				var userMode:UserInfo=new UserInfo();
				userMode.uid=uid;
				userMode.name=nickName;
				userMode.m_wPhotoNum=photoNum;
				userMode.m_byUserRule=userRule;
				userMode.m_userState= userState;
				userMode.m_i64EquipState=equipState;//body.readDouble();	
				userMode.m_i64EquipState2=equipstate2;
				userMode.m_wTuyaImage=0;
				//userMode.sortIndex=sortIndex;
				//userMode.next=userMode.sortIndex+1;
				//userMode.prev=userMode.sortIndex-1;
				//trace("新用户进入：",userMode.starLevel)
				
				RoomModel.getRoomModel().delLeave(uid);
				
				if(ConstVal.isRebroader(uid)){
					return 
				}
				
				RoomModel.getRoomModel().addUserModel(userMode);
				//RoomModel.getRoomModel().userList.sort(RoomModel.getRoomModel().orderList);
				
				
				
				var obj:Object = new Object();
				obj.t = type;
				//obj.userCount =RoomModel.getRoomModel().userList.length;
				obj.roomID = roomId;
				obj.uid = uid
				obj.nickName = nickName;
				obj.photoNum = photoNum;
				obj.userRule = userRule;
				obj.userState = userState;
				obj.equipState = equipState;
				obj.equipState2 = equipstate2;
				//obj.tuyaImg = tuyaImg;
				obj.comeinTip = comeinTip;
				obj.nickName=RoomModel.getRoomModel().getUserName(uid);
				//obj.sortIndex = sortIndex;
				obj.nobility=userMode.nobility;
				
				
				obj.userCount=RoomModel.getRoomModel().totalUser;
				obj.adminUserCount=RoomModel.getRoomModel().totalAdUser;
				obj.micUserCount=RoomModel.getRoomModel().totalMicUser;
				//trace("CEquip",equipState.toString(2))
				
				
				
				if (RoomModel.getRoomModel().myUserModel.uid == uid) {
					RoomModel.getRoomModel().myUserModel.m_i64EquipState = equipState;
					RoomModel.getRoomModel().myUserModel.m_i64EquipState2 = equipstate2;
					//loginOkDispatch();
					//Log.out("原始：",JSON.stringify(userMode))
					//Log.out("用户自己进入:", userMode.m_userState.toString(2),"禁言",isForbidSpeark());
					//Log.out("本人vip等级：", RoomModel.getRoomModel().myUserModel.byVipGrade);
				}
				//Log.out("1005:"+obj.nickName,obj.uid);
			}catch (e:Error) {
				trace("1005",e.message)
			}
			
			sendToJsObj(obj);
		}
		
		/**
		 * 用户离开1006
		 * @author idzeir modify:20130701
		 * */
		private function _1006(body:ByteArray,type:int=1006):void {
			//trace("+++++++++++++++++++++++++++++++++++用户离开:" + type);
			try{
				var roomID:int = body.readInt();
				var uid:Number = Operation.getOperation().readLong(body);
				var leaveType:int = body.readUnsignedByte();
				var reason:String = Operation.getOperation().readGB2312String(body);
				//Operation.getOperation().readGB2312String(body);			
				
				RoomModel.getRoomModel().addLeave(uid);
				
				var obj:Object = new Object();
				
				obj.t = type;
				obj.roomID = roomID;
				//obj.userCount =RoomModel.getRoomModel().userList.length;
				obj.uid = uid;
				obj.leaveType = leaveType;
				obj.reason = reason;
				obj.nickName=RoomModel.getRoomModel().getUserName(uid);
				
				var userMode:UserInfo = RoomModel.getRoomModel().getUser(obj.uid);
				if (userMode == null||ConstVal.isRebroader(uid)) {
					return;
				}
				RoomModel.getRoomModel().outUserMoudel(uid);
				//RoomModel.getRoomModel().userList.sort(RoomModel.getRoomModel().orderList);				
				obj.nobility = userMode.nobility;	
					
				obj.userCount=RoomModel.getRoomModel().totalUser;
				obj.adminUserCount=RoomModel.getRoomModel().totalAdUser;
				obj.micUserCount = RoomModel.getRoomModel().totalMicUser;				
						
				
				sendToJsObj(obj);
			}catch(e:Error){			
				trace("1006", e.message);
				return;
			}			
			
			if (uid == RoomModel.getRoomModel().myUserInfo.uid)
			{
				//自己被踢出房间
				Log.out("你被踢出房间");
				RoomModel.getRoomModel().iPlayer.delAllMicUser();
				this._socket.GC();
				this.gc();
			}
			//m_proces_server.ProcessLeaveUser(type, roomID, uid, leaveType, reason);
		}
		
		//聊天信息1007
		private function _1007(body:ByteArray,type:int=1007):void {
			//_1027();
			//trace("+++++++++++++++++++++++++++++++++++++++聊天信息:" + type);
			var roomID:int = body.readInt();
			var uid:Number = Operation.getOperation().readLong(body);
			var sessionKey:int = body.readInt();
			var dstUid:Number = Operation.getOperation().readLong(body);
			//trace("================" + dstUid);
			var bIsPrivate:int = body.readUnsignedByte();
			var dataLen:int = body.readShort();
			var dataBuffLen:int = body.readShort();
			var fontColor:int = body.readInt();
			var fontSize:int = body.readShort();
			var effects:int = body.readInt();
			var fontName:String = Operation.getOperation().readGB2312String(body);
			var txtMsg:String = Operation.getOperation().readGB2312String(body);
			
			var obj:Object = new Object();
			obj.t = type;
			obj.roomID = roomID;
			obj.uid = uid;
			obj.nickName=RoomModel.getRoomModel().getUserName(uid);
			obj.dstUid = dstUid;
			obj.dsName=RoomModel.getRoomModel().getUserName(dstUid);
			obj.isPrivate = bIsPrivate;
			obj.fontColor = fontColor;
			obj.fontName = fontName;
			obj.fontSize = fontSize;
			obj.effects = effects;
			obj.txtMsg = txtMsg;
			
			var userMode:UserInfo = RoomModel.getRoomModel().getUser(uid);
			if (userMode != null) {
				obj.equipState = userMode.m_i64EquipState;
			}else {
				
			}
			//Log.out("收信息：",txtMsg);
			sendToJsObj(obj);
			//OperateOtherUser(35001712,5,1)
			//_1048("恭喜顶顶顶顶顶顶顶顶顶",0,0,0,1,"宋体",9,255);
			//OperateOtherUser(35001712,18,2);
			//OperateOtherUser(35444539,18,3);//送鲜花
			//OperateOtherUser(35001712,17,1);//获取鲜花
			//_1048("你好！");
			// trace("message:"+type+"  "+roomID+" "+uid+"  "+sessionKey+"  "+dstUid+"  "+bIsPrivate+"  "+dataLen+"  "+dataBuffLen+"  "+fontColor+"  "+fontSize+"  "+effects+"  "+fontName+"  "+txtMsg);
		}
		//普通礼物通知 1047 烟花也是礼物
		private function _1047(body:ByteArray,type:int=1047):void {
			//trace("+++++++++++++++++++++++++++++++++++++++普通礼" + type);

			var roomID:int = body.readInt();
			var uid:Number = Operation.getOperation().readLong(body);
			var nickName:String = Operation.getOperation().readGB2312String(body);
			var recvUid:Number = Operation.getOperation().readLong(body);
			var recvNickName:String = Operation.getOperation().readGB2312String(body);
			var goodsID:int = body.readInt();
			var baseGoodsID:int = body.readInt();
			var goodsCount:int = body.readInt();
			
			//trace(this.readpacket.position+"    "+this.readpacket.length);
			var describe:String = Operation.getOperation().readGB2312String(body);
			
			var obj:Object = new Object();
			obj.t = type;
			obj.roomID = roomID;
			obj.uid = uid;
			obj.nickName = nickName;
			obj.recnUid = recvUid;
			obj.recvNickName = recvNickName;
			obj.goodsID = goodsID;
			obj.baseGoodsID = baseGoodsID;
			obj.goodsCount = goodsCount;
			obj.desc = describe;			
			/*if (RoomModel.getRoomModel().getUser(obj.recnUid).uid != 0) {
				RoomModel.getRoomModel().getUser(obj.recnUid).m_wTuyaImage=goodsID;
			}*/
			
			
			sendToJsObj(obj);
			//Log.out("收礼物:"+roomID + "   " + uid + "   " + nickName + "   " + recvUid + "   " + recvNickName + "   goodsID=" + goodsID + "   baseGoodsID=" + baseGoodsID + "   " + goodsCount + "   " + describe);
			//m_proces_server.ProcessNormalPresent(type, roomID, uid, nickName, recvUid, recvNickName, goodsID, baseGoodsID, goodsCount, describe);
		}
		//申请资源应答
		private function _1028(body:ByteArray,type:int=1028):void{
			//trace("+++++++++++++++++++++++++++++++++++++++申请资源应答" + type);
			var obj:Object = new Object();
			obj.t = type;
			//房间id
			obj.roomID = body.readInt();
			//uid
			obj.uid=Operation.getOperation().readLong(body);
			//操作类型
			obj.m_byOptType=body.readByte();
			//操作辅助参数(同STRU_CL_CAS_RES_REQUEST_RQ的m_lOtherParam )
			obj.m_lOtherParam=body.readInt();
			//结果 ( 排麦时, 成功返回所在位置, 失败返回 -1;其他操作成功返回1,失败返回0 )
			obj.m_lResult=body.readInt();
			//描述
			obj.m_szDescribe=Operation.getOperation().readGB2312String(body);
			trace("排麦应答："+JSON.stringify(obj));
			//sendToJsObj(obj);
		}

		//小喇�?4011
		private function _4011(body:ByteArray,type:int=4011):void {
			//trace("+++++++++++++++++++++++++++++小喇叭开�?" + type);


			var bugleID:int = body.readInt();
			var uid:Number = Operation.getOperation().readLong(body);
			var nickName:String = Operation.getOperation().readGB2312String(body);
			var roomID:int = body.readInt();
			var bugleType:int = body.readUnsignedByte();
			var backPic:int = body.readUnsignedByte();
			var scope:int = body.readUnsignedByte();
			var repeatTimes:int = body.readUnsignedByte();
			var fontName:String = Operation.getOperation().readGB2312String(body);
			var fontSize:int = body.readUnsignedByte();
			var fontColor:int = body.readInt();
			var msgTxt:String = Operation.getOperation().readGB2312String(body);
			//trace("RoomCmdHandler", msgTxt);
			var obj:Object = new Object();
			obj.t = type;
			obj.bugleID = bugleID;
			obj.uid = uid;//发送者uid
			obj.nickName = nickName;//发送者name
			obj.roomID = roomID;
			obj.bugleType = bugleType;//0小喇叭  1大喇叭
			obj.backPic = backPic;//背景图片
			obj.scope = scope;//
			obj.repeatTimes = repeatTimes;
			obj.fontName = fontName;
			obj.fontSize = fontSize;
			obj.fontColor = fontColor;
			obj.msgTxt = msgTxt;
			
			//sendToJsObj(obj);
			//m_proces_server.ProcessBugleInfo(type, bugleID, uid, nickName, roomID, bugleType, backPic, scope, repeatTimes, fontName, fontSize, fontColor, msgTxt);
			//Many_Data(type);
				//m_proces_server.ProcessBugleInfo(type, bugleID, uid, nickName, roomID, bugleType, backPic, scope, repeatTimes, fontName, fontSize, fontColor, msgTxt);
		}

		

		
		

		//超级礼物通知4010
		private function _4010(body:ByteArray,type:int=4010):void {
			//trace("+++++++++++++++++++++++++++++++++++++++++++++++++超级礼物:" + type);
			var roomID:int = body.readInt();
			var roomName:String = Operation.getOperation().readGB2312String(body);
			var uid:Number = Operation.getOperation().readLong(body);
			var nickName:String = Operation.getOperation().readGB2312String(body);
			var recvUid:Number = Operation.getOperation().readLong(body);
			var recvNickName:String = Operation.getOperation().readGB2312String(body);
			var goodsID:int = body.readInt();
			var baseGoodsID:int = body.readInt();
			var goodsCount:int = body.readInt();
			var sendTime:Number = Operation.getOperation().readLong(body);
			var giftID:int = body.readInt();
			
			var obj:Object = new Object();
			obj.t = type;
			obj.roomID = roomID;
			obj.roomName = roomName;
			obj.uid = uid;
			obj.nickName = nickName;
			obj.recnUid = recvUid;
			obj.recvNickName = recvNickName;
			obj.goodsID = goodsID;
			obj.baseGoodsID = baseGoodsID;
			obj.goodsCount = goodsCount;
			obj.sendTime = sendTime;
			obj.giftID = giftID;
			sendToJsObj(obj);
			//m_proces_server.ProcessSuperPresent(type, roomID, roomName, uid, nickName, recvUid, recvNickName, goodsID, baseGoodsID, goodsCount, sendTime, giftID);
			
		}
		/**
		 * 赠送礼物应答 1046
		 * @param	body
		 * @param	type
		 */
		private function _1046(body:ByteArray,type:int=1046):void {
			trace("+++++++++++++++++++++++++++++++++++++++++++++++++用户赠送礼物应�?" + type);
			var obj:Object = new Object();
			obj.t = type;
			obj.roomID = body.readInt();
			obj.uid = Operation.getOperation().readLong(body);
			obj.nickName=RoomModel.getRoomModel().getUserName(obj.uid);
			obj.key = body.readInt();
			
			obj.recvUid = Operation.getOperation().readLong(body);
			obj.dsName=RoomModel.getRoomModel().getUserName(obj.recvUid);
			obj.m_bIsPrivate = body.readByte();
			
			
			
			
			obj.goodsID= body.readInt();
			obj.baseGoodsID = body.readInt();
			obj.goodsCount = body.readInt();
			
			obj.m_byResult = body.readByte();
			obj.m_pErrReason = Operation.getOperation().readGB2312String(body);
			/*if(obj.m_byResult==1){
				RoomModel.getRoomModel().getUser(obj.recvUid).m_wTuyaImage=obj.goodsID
			}	*/		
			sendToJsObj(obj);
			//m_proces_server.ProcessObj(obj);
		}
		
		/**
		 * 小喇叭应答 1049
		 * @param	body
		 * @param	type
		 */
		private function _1049(body:ByteArray, type:int = 1049):void {
			trace("小喇叭:1049");
			var obj:Object = new Object();
			obj.t = type;
			//用户id
			obj.uid = Operation.getOperation().readLong(body);
			obj.nickName=RoomModel.getRoomModel().getUserName(obj.uid);
			//房间ID
			obj.roomID = body.readInt();
			//结果
			obj.m_byResult = body.readByte();
			//消耗money数
			obj.m_fUsedMoney = body.readFloat();
			//错误信息
			obj.m_szErrInfo = Operation.getOperation().readGB2312String(body);
			trace(JSON.stringify(obj));
			//sendToJsObj(obj);
		}		
		
		private function _1030(body:ByteArray,type:int=1030):void {
			//trace("++++++++++++++++++++++++++++++++向其他用户请求操作应答" + type);
			try {			
				var obj:Object = new Object();
				obj.t = type;
				//房间id	
				obj.m_lRoomID=body.readInt();			 
				//当前发言人ID
				obj.m_i64UserID=Operation.getOperation().readLong(body);	
				//会话密钥
				obj.m_nSessionKey=body.readInt();      
				//被处理用户ID
				obj.m_i64DstUserId=Operation.getOperation().readLong(body);		
				obj.name=RoomModel.getRoomModel().getUserName(obj.m_i64UserID);
				obj.dsName=RoomModel.getRoomModel().getUserName(obj.m_i64DstUserId);
				//操作类型（邀请私�?录音 录像�?
				obj.m_byOptType=body.readUnsignedByte();	
				//其他参数
				obj.m_lOtherParam =body.readInt()// body.readShort();	
				
				//结果 ( 对方是否接受�?)
				obj.m_lResult = body.readUnsignedInt();	
				
				//trace("僧语：",body.length-body.position)
				obj.m_szDescribe = Operation.getOperation().readGB2312String(body,false);	
				//trace("僧语：",body.length-body.position)
			}catch (e:Error) {
				trace("发送聊天消息失败：", e.message);
			}
						
			switch(obj.m_byOptType) {
				case 0:
					Log.out("发送聊天消息失败：", obj.m_lResult, obj.m_i64UserID, obj.m_szDescribe);
					break;
				case 17:			
					Log.out("我当前的鲜花是：", obj.m_lOtherParam);
					ConstVal.FLOWERS = obj.m_lOtherParam;
					//Log.out("_1030向其他用户请求应答：送花",obj.m_i64DstUserId);
					/*if (obj.m_lOtherParam > ConstVal.MAX_FLOWERS_LIMITED) {
						obj.m_lOtherParam = ConstVal.MAX_FLOWERS_LIMITED;
					}	*/				
					
					//Log.out("我当前的鲜花是：", obj.m_lOtherParam);
					break;
				case 18:
					//RoomModel.getRoomModel().iPlayer.addFlower(obj.m_i64DstUserId, obj.m_lOtherParam);
					break;
			}
			sendToJsObj(obj);
			//this.m_proces_server.ProcessObj(obj);
		}

		//房间管理应答1033
		private function _1033(body:ByteArray,type:int=1033):void {
			//trace("++++++++++++++++++++++++++++++++房间管理:" + type);

			var managerID:Number = Operation.getOperation().readLong(body);
			var dstUserID:Number = Operation.getOperation().readLong(body);
			var optType:int = body.readUnsignedByte();
			var otherParam:int = body.readInt();
			var result:int = body.readUnsignedByte();
			var desc:String = Operation.getOperation().readGB2312String(body);
			var managerNickName:String = Operation.getOperation().readGB2312String(body);
			//trace("===============" + managerID + "   " + dstUserID + "   " + optType + "   " + otherParam + "    " + result + "   " + desc + "   " + managerNickName);
			//m_proces_server.ProcessManagerOnRoom(type, managerID, dstUserID, optType, otherParam, result, desc, managerNickName);
			var obj:Object = new Object();
			obj.t = type;
			obj.managerID = managerID;
			obj.dstUserID = dstUserID;
			obj.optType = optType;
			obj.otherParam = otherParam;
			obj.result = result;
			obj.desc = desc;
			obj.managerNickName = managerNickName;
			//Log.out("1033:",JSON.stringify(obj))
			sendToJsObj(obj);
		}

		
		

		//用户状态改�?015
		private function _1015(body:ByteArray,type:int=1015):void {
			var roomID:int = body.readInt();
			var uid:Number = Operation.getOperation().readLong(body);
			var sessionKey:int = body.readInt();
			var newState:int = body.readInt();
			//m_proces_server.ProcessUserStateChg(type, roomID, uid, sessionKey, newState);
			//trace("++++++++++++++++++++++++++++++++用户状态改�?" + type + "    " + newState.toString(2));
			
			var user:UserInfo = RoomModel.getRoomModel().getUser(uid);
			
			if (user != null) {
				user.m_userState = newState;
			}
			
			var obj:Object = new Object();
			obj.t = type;
			obj.roomID = roomID;
			obj.uid = uid;
			obj.nickName=RoomModel.getRoomModel().getUserName(obj.uid);
			obj.sessionKey = sessionKey;
			obj.newState = newState;
			obj.userState = newState;
			sendToJsObj(obj);
		}
		
		//管麦通知�?wrs�?204代替
		private function _1023(body:ByteArray,type:int=1023):void {
			//trace("++++++++++++++++++++++++++++++++管麦通知�?" + type);
			var obj:Object = new Object();
			obj.t = type;
			//管理员ID
			obj.m_i64ManagerId=Operation.getOperation().readLong(body);	
			//被处理的麦序�?
			obj.m_sMicIndex=body.readShort();			
			//状态类�?是否手工管理 是否关闭 是否限制使用 麦时)
			obj.m_byOptType=body.readByte();	
			//状态�?
			obj.m_lOtherParam=body.readInt();	
			//麦类�?
			obj.m_byMicType = body.readByte();	
			
			obj.micCount=RoomModel.getRoomModel().totalMicUser;			
			//trace("1023:",obj.m_byOptType)
			
			sendToJsObj(obj);
			
			//m_proces_server.ProcessObj(obj);
		}

		//对其他用户操做通知
		private function _1029(body:ByteArray,type:int=1029):void {
			//trace("++++++++++++++++++++++++++++对其他用户操�?" + type);
			var roomID:int = body.readInt();
			var uid:Number = Operation.getOperation().readLong(body);
			var sessionKey:int = body.readInt();
			var dstUid:Number = Operation.getOperation().readLong(body);
			var optType:int = body.readByte();
			var otherParam:int = body.readInt();
			//trace(type+"     "+ roomID+"    "+ uid+"   "+ sessionKey+"    "+dstUid+"   "+ optType+"    "+ otherParam);
			//m_proces_server.ProcessAskActionRq(type, roomID, uid, sessionKey, dstUid, optType, otherParam);
			var obj:Object = new Object();
			obj.t = type;
			obj.roomID = roomID;
			obj.uid = uid;
			obj.nickName=RoomModel.getRoomModel().getUserName(obj.uid);
			obj.sessionKey = sessionKey;
			obj.dstUid = dstUid;
			obj.dsName=RoomModel.getRoomModel().getUserName(obj.dstUid);
			obj.optType = optType;
			obj.otherPatam = otherParam;
						
			sendToJsObj(obj);
			
			switch(optType) {				
				case 17:					
					Log.out("我1029",obj.otherPatam)
					break;
				case 18:
					//Log.out("_1029向其他用户请求通知：送花", JSON.stringify(obj));
					RoomModel.getRoomModel().iPlayer.addFlower(dstUid, obj.otherPatam);
					break;
			}
			
		}
		
		//用户名称头像等修�?
		private function _1013(body:ByteArray,type:int=1013):void {
			//trace("++++++++++++++++++++++++++++用户名称头像等修�?" + type);
			var obj:Object = new Object();
			obj.t = type;
			//long	m_lRoomID;				//房间id
			obj.roomID = body.readInt();    
			//INT64	m_i64UserID;			//来源用户ID
			obj.uid = Operation.getOperation().readLong(body);    
			//long    m_nSessionKey;          //会话密钥
			obj.sessionKey= body.readInt(); 
			//TCHAR	m_szNickName[DEF_NICK_NAME_LEN + 1];//用户昵称
			obj.nickName = Operation.getOperation().readGB2312String(body);
			//WORD	m_wPhotoNum;
			obj.m_wPhotoNum = body.readShort(); 
			
			var user:UserInfo = RoomModel.getRoomModel().getUser(obj.uid);
			if (user != null) {
				user.name = obj.nickName;
				user.m_wPhotoNum = obj.m_wPhotoNum;
			}
			
			sendToJsObj(obj);
			
		}

		/**
		 * 房间属性通知1016
		 * enum enum_Room_Property_Type
		   {
				enum_Room_Property_Name,              //房间名称
				enum_Room_Property_General,           //常规属性
				enum_Room_Property_Topic,             //房间主题
				enum_Room_Property_Welcome,           //房间欢迎词
				enum_Room_Property_RoomPwd,           //房间密码	
				enum_Room_Property_State,        5     //房间状态
				enum_Room_Property_MicCount,          //麦的个数
				enum_Room_Property_AudioConf,         //语音配置
				enum_Room_Property_VideoConf,         //视频配置
				enum_Room_Property_BbsUrl,        9    //房间BBS地址
				enum_Room_Property_BkPicUrl,          //房间背景
				enum_Room_Property_FiltWord,          //过滤词
				enum_Room_Property_CurPlugID,		  //当前房间插件id
				enum_Room_Property_Charge,			  //收费属性
				enum_Room_Property_PlugInfo,		  //房间可用的插件信息
				enum_Room_Property_JobID,		15	  //房间支持的明星职业id(单字节整形数据)
         };
		 */
		private function _1016(body:ByteArray,type:int=1016):void {
			
			var propertyList:Array = new Array();

			var propertyCount:int = body.readByte();
			for (var i:uint = 0; i < propertyCount; i++){
				//trace(i);
				var obj:Object = new Object;
				var propertyType:int = body.readShort();
				var dataBuff:*;
				var len:Number = body.readUnsignedShort();
				
				switch(propertyType) {
					case 1:
						dataBuff = body.readInt();
						break;
					case 5:
						dataBuff = body.readInt();				
						RoomModel.getRoomModel().myRoomInfo.roomState = dataBuff;
						RoomModel.getRoomModel().myRoomInfo.isStarRoom = dataBuff >> 5 & 0x1;
						
						if (dataBuff & 0x01 == 1&&ConstVal.DEBUG_MODE) {
							if (ExternalInterface.available) {
								ExternalInterface.call("alert","房间被关闭")
							}
						}
						if (dataBuff >> 1 & 0x01 == 1 && ConstVal.DEBUG_MODE) {
							if (ExternalInterface.available) {
								ExternalInterface.call("alert","房间加锁")
							}
						}
						break;
					case 15:
						dataBuff = body.readByte();	
						Log.out("房间职业等级：", dataBuff);
						break;
					default:
						dataBuff = body.readMultiByte(len, "GB2312");
						break;					
				}
				
				
				obj.propertyType = propertyType;
				obj.propertyCount = propertyCount;
				obj.dataBuff = dataBuff;
				propertyList.push(JSON.stringify(obj));
				//trace("1016 propertyType:",propertyType,len,dataBuff);
			}
			var sendobj:Object = new Object();

			sendobj.t = type;
			sendobj.propertyCount = propertyCount;
			sendobj.propertyList = propertyList;
			sendToJsObj(sendobj);
			
			
		}
		
		//用户上麦通知
		private function _1026(body:ByteArray,type:int=1026):void {
			//Log.out("++++++++++++++++++++++++++++++++++++++用户上麦通知:" + type);
			var obj:Object = new Object();
			obj.t = type;
			//房间id	
			
			obj.m_lRoomID = body.readInt(); 
			//当前发言人ID
			obj.m_i64UserID = Operation.getOperation().readLong(body); 
			//会话密钥
			obj.m_nSessionKey = body.readInt(); 
			//麦序�?
			obj.m_sMicIndex = body.readShort(); 
			//语音流ID
			obj.m_lAudioChannelID = body.readInt(); 
			//视频流id
			obj.m_lVideoChannelID = body.readInt(); 
			//麦类�?
			obj.m_byMicType = body.readByte(); 
			
			var micUser:UserInfo=RoomModel.getRoomModel().getUser(obj.m_i64UserID);
			if(micUser!=null)obj.nickName=micUser.name;
			RoomModel.getRoomModel().addMicUserModel(obj.m_sMicIndex,0,0,0,obj.m_i64UserID,0,0);;
			
			obj.micCount = RoomModel.getRoomModel().totalMicUser;
			
			RoomModel.getRoomModel().iPlayer.addMicUser(micUser, obj.m_sMicIndex);
			//Log.out("用户上麦包：", JSON.stringify(obj));
		}
		
        //管理用户应答  上下麦 临管
		private function _1011(body:ByteArray,type:int=1011):void {
			//trace("---------------------管理用户:1011");
			var obj:Object = new Object();
			obj.t = type;
			//管理员ID
			obj.m_i64ManagerId = Operation.getOperation().readLong(body); 
			//被处理用户ID	
			obj.m_i64DstUserId = Operation.getOperation().readLong(body); 
			//处理类型
			obj.m_byOptType = body.readByte(); 
			//当限时踢出用户时，代表时�?
			obj.m_lOtherParam = body.readInt(); 
			//操作结果 零表示成�?非零表示失败
			obj.m_byResult = body.readByte(); 		
			//当前操作的描�?踢人的话，就是踢人原�?
			
			/***/
			
			var dsUserInfo:UserInfo=null;
			var nicUserInfo:UserInfo=null;
			if(obj.m_i64DstUserId!=0){
				dsUserInfo=RoomModel.getRoomModel().getUser(obj.m_i64DstUserId);
				if(dsUserInfo!=null)obj.dsObj=dsUserInfo.getJsObj();
			}
			if(obj.m_i64ManagerId!=0){
				nicUserInfo=RoomModel.getRoomModel().getUser(obj.m_i64ManagerId);
				if(nicUserInfo!=null)obj.nicObj=nicUserInfo.getJsObj();
			}
			
			
			 
			//递麦 收麦
			//trace("当前操作："+obj.m_byOptType)
			if(obj.m_byOptType==5 && obj.m_byResult==1){				
				if( obj.m_i64DstUserId!=0){
					obj.nickName="";					
					if(dsUserInfo!=null)obj.nickName=dsUserInfo.name;
					RoomModel.getRoomModel().addMicUserModel(obj.m_lOtherParam,0,0,0,obj.m_i64DstUserId,0,0);				
				}else{
					//trace("收麦了",obj.m_lOtherParam)
					obj.dsUid=RoomModel.getRoomModel().deleteMicUserModel(obj.m_lOtherParam);					
					RoomModel.getRoomModel().iPlayer.delMicUser(RoomModel.getRoomModel().getUser(obj.m_i64DstUserId), obj.m_lOtherParam);
				}				
				
				
				
			}else
			
			
			if(obj.m_byOptType==7&& obj.m_byResult==1){				
				
			}
			
			if(obj.m_byOptType==2 && obj.m_byResult==1){//临管
				if(obj.m_lOtherParam==1){
					if (dsUserInfo != null) {
						RoomModel.getRoomModel().getUser(obj.m_i64DstUserId).m_byUserRule = 30;
						RoomModel.getRoomModel().totalAdUser++;
					}
					
				}else{
					if (dsUserInfo != null) {
						RoomModel.getRoomModel().getUser(obj.m_i64DstUserId).m_byUserRule = 0;
						RoomModel.getRoomModel().totalAdUser--;
					}
					//trace(0);
				}
				
				
				
				
				obj.userCount=RoomModel.getRoomModel().totalUser;
				obj.adminUserCount=RoomModel.getRoomModel().totalAdUser;
				obj.micUserCount=RoomModel.getRoomModel().totalMicUser;
			}
				
			
			obj.m_szDescribet = Operation.getOperation().readGB2312String(body);
			
			sendToJsObj(obj);
			
			//被踢出去了
			//DebugPanel.Log(">>>"+obj.m_i64DstUserId+">>"+RoomModel.getRoomModel().myUserModel.uid)
			if(obj.m_byOptType==0&&obj.m_i64DstUserId==RoomModel.getRoomModel().myUserModel.uid){
				//断开cas
				SocketManager.getSocketManager().destroyOneSocket("roomSocket");
				
				//断开流
				trace("你被踢出去了")
				RoomModel.getRoomModel().iPlayer.delAllMicUser();
			}
		}
		
		//全站广播应答 1052
		private function _1052(body:ByteArray,type:int=1052):void {
			trace("全站广播应答 1052");
			var obj:Object = new Object();
			obj.t = type;
			//用户id
			obj.m_i64UserID = Operation.getOperation().readLong(body); 
			//房间ID
			obj.m_lRoomID = body.readInt();
			//结果
			obj.m_byResult = body.readByte();
			//消耗money数
			obj.m_fUsedMoney = body.readFloat();
			//错误信息
			obj.m_szErrInfo = Operation.getOperation().readGB2312String(body);
			//公告类型
			obj.m_byNotifyType = body.readByte();
			
			sendToJsObj(obj);
		}
		/**
		 * 用户资料变化通知 1053
		 *  enum_User_Property_Nick = 0,              //用户昵称
			enum_User_Property_Phono = 1,             //用户头像
	        enum_User_Property_State = 2,             //房间状态
	        enum_User_Property_Rule = 3,              //用户权限
	        enum_User_Property_Equip = 4,             //装备情况
	        enum_User_Property_Tuya = 5,              //涂鸦
		 */
		private function _1053(body:ByteArray,type:int=1053):void {			
			try {	
				var obj:Object = new Object();
				obj.t = type;
				//房间ID
				obj.m_lRoomID = body.readInt();
				//用户id
				obj.m_i64UserID = Operation.getOperation().readLong(body); 
				var len:uint = obj.m_sPropertyCount = body.readByte();			
				
				//属性类型
				obj.m_wPropertyType = body.readShort();
				//数据内容
				Log.out("用户资料变化通知:Type=", obj.m_wPropertyType);
				var userModel:UserInfo = RoomModel.getRoomModel().getUser(obj.m_i64UserID);
				body.readShort();
				if(obj.m_wPropertyType==5){//涂鸦
					obj.m_szDataBuff = body.readShort();
					Log.out("涂鸦：",obj.m_sPropertyCount, obj.m_szDataBuff);
					if(userModel!=null)userModel.m_wTuyaImage=obj.m_szDataBuff;
				}else if (obj.m_wPropertyType == 4) {
					
				}else if (obj.m_wPropertyType == 0) {
					userModel.name = Operation.getOperation().readGB2312String(body);
				}else{
					obj.m_szDataBuff=Operation.getOperation().readGB2312String(body);
				}
			
			
						
				userModel.sortIndex = Operation.getOperation().calculationSortNum(userModel.uid, userModel.m_byUserRule, userModel.m_i64EquipState, userModel.m_i64EquipState2);	
			}catch (error:Error) {
				Log.out(error.message);
			}
						
			sendToJsObj(obj);
		}
		
		//公告通知包 1063
		private function _1063(body:ByteArray,type:int=1063):void {
			trace("公告通知包 1063");
			var obj:Object = new Object();
			obj.t = type;
			//用户id
			obj.m_i64UserID = Operation.getOperation().readLong(body); 
			//房间ID
			obj.m_lRoomID = body.readInt();
			//会话密钥
			obj.m_nSessionKey = body.readInt();
			//公告类型
			obj.m_byNotifyType = body.readByte();
			//公告信息
			obj.m_szNotifyInfo = Operation.getOperation().readGB2312String(body);
			
			sendToJsObj(obj);
			
		}
		
		/**************************************************************************************
		 *明星系列
		 **************************************************************************************/
		//更新明星信息应答包
		private function _3506(body:ByteArray, type:int = 3506):void {
			var obj:Object = new Object();
			obj.t = type;
			//SVRid
			obj.m_lSvrID = body.readInt();
			//会话密钥
			obj.m_lSessionKey = body.readInt();
			//房间id
			obj.m_lRoomID = body.readInt(); 
			//要更新的用户ID
			obj.m_i64UserID = Operation.getOperation().readLong(body); 
			//送的明星的ID
			obj.m_iStarID = Operation.getOperation().readLong(body); 
			//跟新信息以后明星的等级;
			obj.m_lStarLevel = body.readInt();
			//要更新的类型
			obj.m_byUpdateType = body.readByte();
			//更新的职业
			obj.m_lJobID = body.readInt();
			//更新后的数量（数据库最终值）
			obj.m_i64Count = Operation.getOperation().readLong(body); 
			//sendToJsObj(obj);
			Log.out("CAS更新明星信息应答包：",JSON.stringify(obj))
		}
		//用户明星信息应答包
		private function _3504(body:ByteArray, type:int = 3504):void {
			var obj:Object = new Object();
			obj.t = type;
			//SVRid
			obj.m_lSvrID = body.readInt();
			//会话密钥
			obj.m_lSessionKey = body.readInt();
			//请求的用户信息
			obj.m_i64UserID = Operation.getOperation().readLong(body); 
			//房间id
			obj.m_lRoomID = body.readInt(); 
			//自己所拥有的明星礼物数量
			obj.m_lOwnGiftCount = body.readInt();
			//明星的先关信息
			////职业的类型ID
			obj.lJobTypeID=body.readInt();
			//职业的等级
			obj.lJobLevel=body.readInt();
			//明星的粉丝数量
            obj.lFansCount=body.readInt();
			//明星的职业礼物数量
			obj.m_lJobGiftCount=body.readInt();
			//sendToJsObj(obj);
			Log.out("CAS用户明星信息应答包：",JSON.stringify(obj))
		}
		//职业信息应答
		private function _3507(body:ByteArray, type:int = 3507):void{
			var obj:Object = new Object();
			obj.t = type;
			//SVRid
			obj.m_lSvrID = body.readInt();
			//会话密钥
			obj.m_lSessionKey = body.readInt();
			//发生变化的房间，用户客户端校验
			obj.m_lRoomID = body.readInt();
			//请求的职业ID
			obj.m_lJobID=body.readInt();
			//获取礼物需要的时间
			obj.m_i64GetGiftTime=Operation.getOperation().readLong(body);
			//sendToJsObj(obj);
			Log.out("CAS职业信息应答：",JSON.stringify(obj))
		}
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//登陆cas
		private function _1039():void {			
			whandle(write._1039());
		}
		
		
		
		//聊天
		public function Client_To_Server_message(DstUserID:Number = 0, fontColor:int = 0, fontSize:int = 11, effects:int = 1, fontName:String = "宋", mes:String = "大家好", Private:int = 0):void {
			
			Log.out("允许发言:",isForbidSpeark(RoomModel.getRoomModel().myUserInfo.uid),DstUserID,Private,mes)
			whandle(write._1007(DstUserID, fontColor, fontSize, effects, fontName, mes, Private));
		}
		//送礼物
		public function Song_li_Wu(RecvUserID:int = 0, m_lGoodsID:int = 1605, m_lBaseGoodsID:int = 7412, m_lGoodsCount:int = 1):void {
			
			whandle(write._1045(RecvUserID,m_lGoodsID,m_lBaseGoodsID,m_lGoodsCount));
		}
		
		/**
		 * 对其他用户操作 1029
		 *@param RecvUserID:操作的用户ID  默认:0大家
		 *@param type:操作类型
		 *@param lOtherParam:其他参数
		 */
		public function OperateOtherUser(RecvUserID:int = 0, type:int = 5, lOtherParam:int = 4):void {
			whandle(write._1029(RecvUserID, type, lOtherParam));
		}
		//管理用户
		public function RoomOperateOtherUser(adminId:int, RecvUserID:int, type:int, mes:String,time:Number):void {
			whandle(write._1010(adminId,RecvUserID,type,mes,time));
		}
		
		
		/**
		 *发送小喇叭 1048
		 *@param m_byBugleType :喇叭类型 0小喇叭 默认0
		 *@param m_byBackPic:背景图片id 默认0
		 *@param m_byScope:范围 默认0
		 *@param m_byRepeatTimes:重复次数 默认1
		 *@param m_szFontName:字体
		 *@param m_byFontSize:大小
		 *@param m_dwFontColor:字体颜色
		 *@param mes:喇叭消息
		 */
		public function _1048( mes:String,m_byBugleType:Number=0, m_byBackPic:Number=0, m_byScope:Number=0, m_byRepeatTimes:Number=1, m_szFontName:String="宋", m_byFontSize:Number=12, m_dwFontColor:Number=255):void {
			//废弃老版本喇叭whandle(write._1048(mes,m_byBugleType, m_byBackPic, m_byScope, m_byRepeatTimes, m_szFontName, m_byFontSize, m_dwFontColor));
			whandle(write._1153(mes,m_byBugleType, m_byBackPic, m_byScope, m_byRepeatTimes, m_szFontName, m_byFontSize, m_dwFontColor));
		}
		
		//全站广播
		public function _1051(m_byScope:Number, fontName:String, fSize:Number, fColor:Number, mes:String, m_byNotifyType:Number):void {
			whandle(write._1051(m_byScope, fontName, fSize, fColor, mes, m_byNotifyType));
		}
		//房间管理
		public function _1032(type:Number,dsUid:Number,mParam:Number,tchar:*):void{
			whandle(write._1032(type,dsUid,mParam,tchar));
		}
		
		//发送语音
		public function write_1026(mic:int,m_lAudioChannelID:Number,m_lVideoChannelID:Number,m_byMicType:int):void{
			whandle(write._1026(mic,m_lAudioChannelID,m_lVideoChannelID,m_byMicType));
		}
		
		//申请资源
		public function _1027(m_byOptType:int=4,m_lOtherParam:int=1):void{
			//DebugPanel.Log("资源申请：m_byOptType>"+m_byOptType+" m_lOtherParam>"+m_lOtherParam);
			whandle(write._1027(m_byOptType,m_lOtherParam));
		}
		/**
		 * 用户属性修改
		 * @param type 类型 
		 * @param str 值 
		 */
		public function _1054(type:int,str:String):void{
			whandle(write._1054(type,str));
		}
		
		//明星 送花
		public function _3505(m_lSvrID:Number,m_iStarID:Number,m_lUserLevel:Number,m_byUpdateType:Number,m_lJobID:Number,m_lCount:Number):void { 
			whandle(write._3505(m_lSvrID,m_iStarID,m_lUserLevel,m_byUpdateType,m_lJobID,m_lCount));
		}
		
		public function _3503(m_lSvrID:Number,m_byType:Number,m_lJobID:Number,m_iExtend64Value:Number):void {
			whandle(write._3503(m_lSvrID,m_byType,m_lJobID,m_iExtend64Value));
		}
		
		public function loginOut():void
		{
			whandle(write._1018());
			RoomModel.getRoomModel().iPlayer.delAllMicUser();
		}
	}

}