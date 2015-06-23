package com.guagua.chat {
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.util.Operation;
	import com.guagua.utils.ConstVal;
	import flash.utils.setTimeout;
	
	import com.guagua.chat.Server.ServerMain;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.net.handler.room.*;
	import flash.external.ExternalInterface;

	/**
	 * ...
	 * @author Wen
	 */
	
	public class CommServer
	{
		//房间文档类
		private var room:ServerMain;
		
		static private var instance:CommServer;
		
		public function CommServer(arg:InterArgError):void {
			setUp();	
		}
		
		static public function getInstance():CommServer
		{
			if (!instance) {
				instance = new CommServer(new InterArgError());
			}
			return instance;
		}
	
        //网页参数读取  加密接口
		public function setUp(obj:Object = null):void {
			Log.out("初始化播放器成功：[CommServer]")
			//财经专属oemid 8  娱乐oemid 0
			RoomModel.getRoomModel().m_lOemID=7;
			room = new ServerMain();
			if (ExternalInterface.available)
			{				
				ExternalInterface.addCallback("getWebParam", this.getWebParam);
				try {
					ExternalInterface.call("swfLoadComplete");		
				}catch (e:Error) {
					trace("未定义js函数","swfLoadComplete")
				}
					
			}
		}			
		
		/////////////////////////////////////////
		public function getWebParam(userModel:Object, ipModel:Object, roomModel:Object,cas:Object=null) : void
		{	
			if (arguments.length < 3) {
				Log.errorMsg("error in [ getWebParam ]:", "参数数量不正确");
				return;
			}
		
			try {
				var jsobj_s:Object=JSON.parse(userModel.s)
				
				RoomModel.getRoomModel().addServers(ConstVal.SERVER_TYPE_CAS, jsobj_s.casAddr);
				RoomModel.getRoomModel().addServers(ConstVal.SERVER_TYPE_ACS, jsobj_s.acsAddr);
				RoomModel.getRoomModel().addServers(ConstVal.SERVER_TYPE_BSP, jsobj_s.bspAddr);
				RoomModel.getRoomModel().addServers(ConstVal.SERVER_TYPE_CQS, jsobj_s.cqsAddr);
				
				//roomModel.roomId = "2012600";
				/*var namestr:String="我是你的"
				userModel.name = namestr;*/				
				Log.out("=======================");
				Log.out("※用户数据：\n" + JSON.stringify( { uid:userModel.uid, name:userModel.name, rule:userModel.rule, face:userModel.face, meck:userModel.meck } ));
				Log.out("※服务器数据：\n" + JSON.stringify( { casIP:ipModel.casAddr } ) + "\n" + JSON.stringify( { acsIP:ipModel.acsAddr } ) + "\n" + JSON.stringify( { bspIP:ipModel.bspAddr } ) + "\n" + JSON.stringify( { cqsIP:ipModel.cqsAddr } ));
				Log.out("※房间数据：\n" + JSON.stringify( { roomID:ipModel.roomId, roomName:ipModel.roomName, roomPWD:roomModel.roomPwd } ));
				Log.out("=======================");
				if (userModel.uid == null) {
					Log.errorMsg("error in [ getWebParam ]:", "*uid is null*");
					return;
				}
				if (userModel.name == null) {
					Log.errorMsg("error in [ getWebParam ]:", "*name is null*");
					return;
				}
				if (roomModel.roomId == null) {
					Log.errorMsg("error in [ getWebParam ]:", "*roomId is null*");
					return;
				}
				if (roomModel.roomPwd == null) {
					Log.errorMsg("error in [ getWebParam ]:", "*roomPwd is null*");
					return;
				}
				if (userModel.net == null) {
					Log.errorMsg("error in [ getWebParam ]:", "*net is null*");
					return;
				}				
				
				this.room.initUser(userModel.uid, userModel.name, userModel.meck, roomModel.roomId, roomModel.roomPwd, userModel.face, userModel.tuya, userModel.rule, userModel.state, userModel.cVer, userModel.net, userModel.media32);
				
				//var isIpOK:Boolean=this.setServerIp();
			}catch(e:Error){				
				Log.errorMsg("error in [ getWebParam ]:", e.message);
			}	
			
			loginCheck()	
		}	
		
		/**
		 * 对获取的服务器地址进行验证。
		 * */
		private function loginCheck():void
		{
			if (setServerIp())
			{
				this.room.login();	
				return;
			}
			
			var timeOutFun:Function = function()
			{
				Log.out("服务器地址出错，0.5秒以后重连");
				//ErrorToServerMgr.getLocal().add( {errorID:100,serverIp:"",serverPort:0,col1:"js传给flash初始数据有误"} );
				loginCheck();
			}
			
			setTimeout(timeOutFun, 500);
		}
		
		private function setServerIp():Boolean
		{
			var bspIp:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_BSP);			
			var cqsIp:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_CQS);
			var acsIp:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_ACS);			
			var casIp:IpInfo = RoomModel.getRoomModel().getServer(ConstVal.SERVER_TYPE_CAS);			
			
			if (casIp==null||casIp.ip==""||casIp.ip=="0.0.0.0"||isNaN(Number(casIp.port))) {
				Log.errorMsg("error in [ setServerIp ]:", "cas ip is error!", JSON.stringify(casIp));
				return false;
			}
			if (bspIp==null) {
				Log.errorMsg("error in [ setServerIp ]:", "bspIp ip is error!", JSON.stringify(bspIp));
				return false;
			}
			if (acsIp==null) {
				Log.errorMsg("error in [ setServerIp ]:", "acsIp ip is error!", JSON.stringify(acsIp));
				return false;
			}		
			//this.room.initServer("192.168.100.115", 6200, cqsIp.ip, Number(cqsIp.port), bspIp.ip, Number(bspIp.port), acsIp.ip, Number(acsIp.port));
			//this.room.initServer(casIp.ip, Number(casIp.port), cqsIp.ip, Number(cqsIp.port), bspIp.ip, Number(bspIp.port), acsIp.ip, Number(acsIp.port));		
			return true;
		}				
		
		public function debug(ss:Object=null,pwd:String=""):void{
			//ss = { "f":2045514361, "isLogin":1, "id":148631390, "face":0, "s":"{\"acsAddr\":\"1014829433:9600,1031606649:9600,1048383865:9600,1065161081:9600,1081938297:9600,671349284:9600,688126500:9600,704903716:9600,721680932:9600,738458148:9600,916152188:7010,765157244:11000,781934460:11000,798711676:11000,815488892:11000\",\"bspAddr\":\"904663673:13332,921440889:14333,938218105:14333,954995321:14333,971772537:14333,988549753:14333,1005326969:14333,787223161:3569,804000377:2909,513499004:3569\",\"casAddr\":\"1026612538:12200,1026612538:12300,1026612538:12400,1244716346:12000,1244716346:12100,1244716346:12200,1244716346:12300,1244716346:12400,1261493562:12400,1261493562:12000,1261493562:12100,1261493562:12200,1261493562:12300,1278270778:12000,1278270778:12100,1278270778:12200,1278270778:12300,1043389754:12000,1043389754:12100,1043389754:12200,607182138:12000\",\"cqsAddr\":\"362504060:17500,379281276:17500,396058492:17500,310186361:16500\",\"micNum\":3,\"property\":-1070624733,\"roomId\":20131314,\"roomName\":\"呱呱官方测试房间\",\"state\":112}", "name":"隆隆_Dzeir", "roomId":20131314, "ft":1935, "isptype":1, "bRoomExist":1, "room": { "onlinecount":0, "favcount":0 }, "meck":"44d826dd2bfc49a09c2efdbb6caaba17ea664b306c6c314a7f3ea2a183350b62" };
			
			var userObj:Object=new Object();
			userObj.cVer=34;//客户端版本
			userObj.net = ss.isptype;//网路类型
			userObj.meck = ss.meck;
			userObj.uid = ss.id;
			userObj.name = ss.name;
			
			userObj.tuya=0;//涂鸦
			userObj.face=0;//头像
			userObj.rule=0;//用户权限
			userObj.media32 =null;//媒体参数
			
			userObj.s=ss.s;			
		//	trace("===========================================");
			var ipObj:Object=JSON.parse(ss.s);
			//userObj.net = ipObj.net;
			
			var roomObj:Object=new Object();
			roomObj.roomId=ipObj.roomId;
			//roomObj.roomName=ipObj.roomName;
			roomObj.roomPwd = pwd==""?"0":pwd;
			
			getWebParam(userObj,ipObj,roomObj);
			//trace("wo yao dengl")
			
		}

	}	
}
class InterArgError{}