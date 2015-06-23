package com.guagua.chat.model 
{
	import com.guagua.chat.model.IpInfo;
	import com.guagua.chat.model.MicUserInfo;
	import com.guagua.chat.model.RoomInfo;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.util.Operation;
	import com.guagua.interfaces.IPlayer;
	import com.guagua.utils.ConstVal;
	import flash.text.TextField;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import com.guagua.chat.net.handler.bsp.BspCmdHandler;
	import com.guagua.chat.net.handler.room.RoomCmdHandler;
	/**
	 * ...
	 * @author Wen
	 */
	public class RoomModel extends EventDispatcher
	{
		/**
		 *用户列表
		 */
		private var _userList:Vector.<UserInfo> = new Vector.<UserInfo>();
		/**
		 * 麦上用户列表
		 * */
		public var micUserList:Vector.<MicUserInfo>=new Vector.<MicUserInfo>();
		/**
		 * 麦序 用户ID 列表   在解包1024里操作
		 */
		public var micXUserIDList:Array=[];
		/**
		 * 麦序用户是否都有名字
		 */
		/**cas ip 列表**/
		public var casList:Vector.<IpInfo>=new Vector.<IpInfo>;
		
		public var micXNameIsOk:Boolean=true;
		/**
		 * 房间模型
		 */
		public var myRoomInfo:RoomInfo;
		/**
		 * 网页用户模型
		 */
		public var myUserModel:UserInfo;
		/**
		 * 进入的房间
		 */
		public var thisRoomID:Number;
		/**
		 * 登陆房间网络类型
		 */
		public var m_byIspType:int = 0;
		/**
		 * 登陆房间NAT类型
		 */
		public var m_byNatType:int = 0; 
		/**
		 *客户端版
		 */
		public var m_wClientVer:int =30//29; 
		/**
		 * 房间策略端口
		 */
		public var securityPort:uint = 843;
		/**
		 * 房间区别登陆用户和游客区别
		 */
		public var maxUid:Number = 10000000000;
		/**
		 * 用户列表分页ID
		 */
		public var pageIndex:int=1;
		/**
		 * 每页用户多少人
		 */
		public var userListTotal:int=20;
		/**
		 * 通信唯一key
		 */
		public var key:Number=0;
		/**
		 * cas ip
		 */
		public var roomProxyIp:String;
		/**
		 * cas port
		 */
		public var roomProxyPort:uint;
		//wbs ip
		public var wbsIp:String="121.18.236.115";
		public var wbsPort:Number=6706;
		//cqs  ip
		/*public var cqsIp:String="192.168.100.51";//"1192.168.24.244";
		public var cqsPort:Number=7100;//5000
		//Bsp
		public var bspIp:String="192.168.100.51";//"192.168.24.193";
		public var bspProt:Number=5502;//6789;*/
		public var cqsIp:String="59.47.50.20";//"1192.168.24.244";
		public var cqsPort:Number=3264;//5000
		//Bsp
		public var bspIp:String="59.47.50.20";//"192.168.24.193";
		public var bspProt:Number=8181;
		//goods
		public var goodsIp:String="59.47.50.20";//"192.168.100.51";
		public var goodsProt:Number=7312;//4100;
		
		
		/**
		 * 初始化加密串C++:66CBC149-A49F-48F9-B17A-6A3EA9B42A87 比flash多4位
		 */
		public var initKey:String = "66CBC149-A49F-48F9-B17A-6A3EA9B4";
		
		/**
		 * res加密串C++:F1806AA2-BFE0-429f-88C4-F2757E3A5DDA 比flash多4位
		 * */
		public var resKey:String = "F1806AA2-BFE0-429f-88C4-F2757E3A";
		 
		/**
		 * 获取服务器IP地址
		 */
		public var serverIpUrl:String = "http://v.guagua.cn/chatroom/getCasList.do?roomId=";
		
		/**
		 *产品ID
		 */
		public var m_lOemID:int=0;
		
		private static var instance:RoomModel;		
		
		/**明星服务器API*/
		public var bspAPI:BspCmdHandler
		/**CAS服务器API*/
		public var casAPI:RoomCmdHandler;
		/**日志文本*/
		public var debugAPI:TextField;
		
		/**播放器接口*/
		public var iPlayer:IPlayer;		
		
		/**离开用户列表，用于解决1040晚于1006包回来导致的用户数不对*/
		private var leaveUsers:Vector.<Number> = new Vector.<Number>();
		
		/**给web页面的小数据组，初始20个*/
		public var webUsers:Vector.<UserInfo> = new Vector.<UserInfo>();
		/**给web页面推数据的时候，缓存执行用户进入退出*/
		private var cacheArr:Vector.<UserInfo> = new Vector.<UserInfo>();
		
		/**ACS信息返回标识*/
		public var isACS:Boolean = false;
		
		/**ACS和BSP服务器列表*/
		private var serverMap:Vector.<IpInfo> = new Vector.<IpInfo>();
		
		public var isSending:Boolean = false;		
		
		/**管理员用户数量*/
		private var adminCount:uint = 0;
		
		public var videoStyleIndex:uint = 0;
		
		public function RoomModel() 
		{
			micUserList.push(new MicUserInfo(0));
			micUserList.push(new MicUserInfo(1));
			micUserList.push(new MicUserInfo(2));
		}
		
		public static function getRoomModel():RoomModel {
			if (instance == null) {
				instance = new RoomModel();
			}
			return instance;
		}
		
		public function showInfo(str:String):void
		{
			debugAPI.appendText(str);			
			debugAPI.scrollV = debugAPI.maxScrollV;
		}
		/*1491866233:7200,1508643449:7200,1525420665:7200,1542197881:7200,1558975097:7200,1424757369:8900,720114297:3690,916152188:7010,765157244:11000,781934460:11000,798711676:11000,815488892:11000*/
		
		/*
		 * 添加acs和bsp服务器列表;
		 * @param type 服务器类型，"acs","bsp";
		 * @param ipStr 服务器数据字符串
		 * */
		public function addServers(type:String, ipStr:String):void {
			var ipStrArr:Array = ipStr.split(",");
			
			var len:uint = ipStrArr.length;
			
			for (var i:uint = 0; i < len; i++) {
				var ip:IpInfo = new IpInfo();
				
				ip.ip = Operation.getOperation().intIp2Str(Number(ipStrArr[i].split(":")[0]));
				ip.port = ipStrArr[i].split(":")[1];				
				ip.type = type;				
				this.serverMap.push(ip);
			}
			//Log.out("AddServers:"+type+"\n",serversToString(type),"\n");
		}
		
		/**
		 * 获取指定类型的服务器ip模型
		 * @param type:String "acs","bsp"等;
		 * @return ipInfor 返回可用服务器
		 * */
		public function getServer(type:String):IpInfo {				
			var typedServer:Vector.<IpInfo> = getServerMapByType(type);				
			for each(var i:IpInfo in typedServer)
			{
				if (i.isNormal)
				{
					return i;
				}
			}
			
			resetServerToNormal(typedServer);			
			var index:uint = Math.floor(Math.random() * typedServer.length);
			return typedServer[index];
		}
		
		/**
		 * 服务器都不可用时候重置map里面服务器状态
		 * @param map:Vector.<IpInfo>需要重置的服务列表类型
		 * */
		private function resetServerToNormal(map:Vector.<IpInfo>):void
		{
			if (map.length > 0)
			{
				for each(var i:IpInfo in map)
				{
					i.isNormal = true;
				}
			}
		}
		
		/**
		 * 从整个服务器map中提取所有指定类型服务器
		 * @param type:String 服务器类型
		 * @return 数组列表包含查找类型的服务器
		 * */
		private function getServerMapByType(type:String):Vector.<IpInfo>
		{
			var _temp:Vector.<IpInfo> = new Vector.<IpInfo>();
			for each(var i:IpInfo in serverMap)
			{
				if (i.type == type)
				{
					_temp.push(i);
				}
			}
			return _temp;
		}
		
		
		public function serversToString(type:String):String {
			var sz:String = "";
			for each(var i:IpInfo in serverMap) {
				if (type != i.type) continue;
				sz += i.toString()+"\n";
			}
			return sz;
		}
		
		
		/**添加cas列表**/
		public function addCasIpList(ipStr:String):void{
			var ipStrAry:Array=ipStr.split(",");
			for(var i:int=0;i<ipStrAry.length;i++){
				var sAry:Array=ipStrAry[i].split(":");
				var ip:IpInfo=new IpInfo();
				ip.ip=sAry[0];
				ip.port=Number(sAry[1]);
				ip.type=ConstVal.SERVER_TYPE_CAS;
				casList.push(ip);
				Log.out("CAS地址列表：",ip.ip,ip.port);
			}	
			Log.out("CAS地址列表下载完成");
		}
		
		/**加入离开用户id*/
		public function addLeave(id:Number):Boolean {
			if (isLeave(id)) {
				return false;
			}
			leaveUsers.push(id);
			return true;
		}
		
		/**用户进入重离开列表移除*/
		public function delLeave(id:Number):Boolean {
			
			for (var i:Number = 0; i < leaveUsers.length; i++) {
				if (leaveUsers[i] == id) {
					leaveUsers.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		
		/**判断用户是否在离开列表*/
		public function isLeave(id:Number):Boolean {
			for each(var i:Number in leaveUsers) {
				if (i == id) {
					return true;
				}
			}
			return false;
		}
		
		public function addIp(ip:IpInfo):void {			
			casList.push(ip);
		}
		
		/**cas 状态设置 
		 * @param ip
		 * @param port
		 * @param b:true可以用
		 * @param type
		 */
		public function setServerStatusByIp(ip:String,port:uint,b:Boolean,type:String=ConstVal.SERVER_TYPE_CAS):void{
			for each(var i:IpInfo in serverMap)
			{
				if (i.ip == ip && i.port == port&&i.type==type)
				{
					i.isNormal = b;
					return;
				}
			}
		}
		
		/**cas 状态设置 （弃用 web2.0）
		 * @param ip
		 * @param port 端口
		 * @param b:true可以用
		 * @param type
		 * 
		 */
		public function setServerStatus(ip:String,port:String,b:Boolean,type:String=ConstVal.SERVER_TYPE_CAS):void{
			if(casList.length==0){
				return;
			}
			for(var i:int=0;i<casList.length;i++){
				if(casList[i].ip==ip && type==casList[i].type&&casList[i].port==uint(port)){
					casList[i].isNormal=b;
					//if(!b)casList.splice(i,1);
					return;
				}
			}
		}
		
		/**web2.0弃用*/
		public function resetSrsIp(type:String = ConstVal.SERVER_TYPE_CAS):IpInfo {
			var ip:IpInfo;
			for(var i:int=0;i<casList.length;i++){
				if (type == casList[i].type) {
					casList[i].isNormal = true;	
					ip = casList[i];
				}
			}
			return ip;
		}
		
		/**获取新ip(web2.0弃用)**/
		public function getSrsIp(type:String=ConstVal.SERVER_TYPE_CAS):IpInfo{
			for(var i:int=0;i<casList.length;i++){
				if(type==casList[i].type && casList[i].isNormal){
					return casList[i];
				}
			}
			return null;
		}
		
		/**设置服务器IP 端口**/
		public function setIp(ip:String,port:Number,type:String):void{
			switch(type){
				case ConstVal.SERVER_TYPE_CAS:
					roomProxyIp = ip;
					roomProxyPort = port;
					break;
				case ConstVal.SERVER_TYPE_CQS:
					cqsIp=ip;
					cqsPort=port;
					break;
				case ConstVal.SERVER_TYPE_BSP:
					bspIp=ip;
					bspProt=port;
					break;
				case ConstVal.SERVER_TYPE_ACS:
					goodsIp=ip;
					goodsProt=port;		
					break;	
			}
			/*
			var ipNode:IpInfo = new IpInfo();
			ipNode.ip = ip;
			ipNode.port = port;
			ipNode.type = type;
			ipNode.isNormal = true;
			
			this.addIp(ipNode);*/
		}
		
		/**
		 * 设置产品类型
		 */
		public function setM_lOemID(emId:int=7):void{
			m_lOemID=7;
		}
		/**
		 * 网页用户模型
		 */
		public function addWebUserIn(uid:Number, name:String, meck:String, wPhotoNum:int , m_wTuyaImage:int, byUserRule:int, EquipState:Number, Media:Array,net:Number):void {	
			if (myUserModel == null) {
				myUserModel = new UserInfo();
							
			}
			myUserModel.uid = uid;
			myUserModel.isLongUser =  uid > maxUid?myUserModel.isLongUser = true:myUserModel.isLongUser;
			myUserModel.name = name;
			myUserModel.mesk = meck;
			if(myUserModel.isLongUser)myUserModel.mesk="3e4fffd6ed79e856123282173876fc148cda82b253682110cd3464fe0614826d";
			myUserModel.m_wPhotoNum = wPhotoNum;
			myUserModel.m_wTuyaImage = m_wTuyaImage;
			myUserModel.m_byUserRule = byUserRule;
			myUserModel.m_i64EquipState = EquipState;
			myUserModel.sortIndex = 0;
			this.m_byIspType = net;
			if(Media)myUserModel.m_Media = null;
			
			//var result:Boolean=addUserModel(myUserModel);			
		}
		
		/**用户自己是否被禁言*/
		public function get isForbidSpeark():Number {
			Log.out("允许发言:",this.getUser(myUserModel.uid).m_userState & 0x1)
			return this.getUser(myUserModel.uid).m_userState & 0x1;
		}
		
		/**
		 * 增加用户模型
		 * @param uModel:UserInfo用户模型
		 * @param inner:Boolean 默认false，为true时，处理的是缓存的数据
		 * @return 正常插入返回true，缓存时返回false
		 */
		public function addUserModel(uModel:UserInfo, inner:Boolean = false):Boolean {
			//传给js数据过程中缓存数据
			if (isSending&&!inner) {
				uModel.COMEIN = true;
				cacheArr.push(uModel)
				return false
			}
			
			var inList:Boolean = false;
			for each(var i:UserInfo in _userList) {
				if (i.uid == uModel.uid) {
					inList = true;
				}
			}
			if (!inList) {
				//无序压入用户列表				
				var resTree:ResTree = ResTree.getInstance();
				var m_lLimitStarLevel:Number = 10;
				var llResID:Number = myRoomInfo.isStarRoom << 7;
				llResID |= 0x01;
				llResID += 50000;
				
				if (resTree.hasNode(llResID)) {	
					m_lLimitStarLevel = resTree.getResProperty(llResID);
				}				
				uModel.sortIndex = Operation.getOperation().calculationSortNum(uModel.uid, uModel.m_byUserRule, uModel.m_i64EquipState, uModel.m_i64EquipState2, m_lLimitStarLevel);
				_userList.push(uModel);	
			}
			var inWebList:Boolean = false;
			for each(i in webUsers) {
				if (i.uid == uModel.uid) {
					inWebList = true;
				}
			}
			
			if (inWebList) {
				return false;
			}
			//压入web用户列表，排序
			webUsers.push(uModel);
			webUsers.sort(orderList);
			//截取web用户列表。
			webUsers.splice(0, pageIndex * this.userListTotal);				
			//如果web用户不足，填充用户列表
			fillWebUser()	
			
			uModel.COMEIN = true;
			//计数管理员
			if (uModel.m_byUserRule > 0) {
				adminCount++;
			}
			
			return true;
		}		
		
		/**
		 * 处理给js推用户的过程中，产生的缓存用户
		 * */
		public function deailCache():void {
			isSending = false;
			if (cacheArr.length <= 0) {
				//Log.out("没有缓存")
				return;
			}
			
			//Log.out("居然还真有缓存：", cacheArr.length);
			var len:uint = cacheArr.length;
			
			for each(var i:UserInfo in cacheArr) {
				if (i.COMEIN) {
					addUserModel(i, true);
				}else {
					outUserMoudel(i.uid, true);
				}
			}
			cacheArr = new Vector.<UserInfo>();
			Log.out("缓存清理完成：", cacheArr.length+"/"+len);			
		}
		
		/**
		 * webusers用户不足时候，对整个用户列表排序，
		 * 并且给webUsers补充用户
		 * */
		private function fillWebUser():void {
			if (webUsers.length < pageIndex * this.userListTotal) {
				sortOrder();
				var temp:Vector.<UserInfo> = _userList.concat();
				webUsers = temp.splice(0, pageIndex * this.userListTotal);				
			}
			
		}
		
		/**将用户模型转换成object数组*/
		public function webUserToArrObj():Array {
			var arr:Array = [];			
			
			for each(var i:UserInfo in webUsers) {
				arr.push(i.getJsObj());
			}
			return arr;
		}
		
		/**按sortIndex对用户列表大到小排序*/
		public function orderList(a:UserInfo, b:UserInfo):Number {			
			if(a.sortIndex>b.sortIndex){
				return -1;
			}else if(a.sortIndex<b.sortIndex){
				return 1;
			}
			return 0
		}
		
		public function sortOrder():void {
			_userList.sort(orderList);
		}
		
		/**
		 * 用户离开
		 * @param uid:Number 离开用户的id
		 * @param inner:Boolean 默认false，为true时，处理的是缓存的数据
		 * @return 返回离开用户模型，错误时返回null
		 */
		public function outUserMoudel(uid:Number,inner:Boolean=false):UserInfo{			
			var user:UserInfo = getUser(uid);		
			//缓存用户
			if (isSending && !inner) {
				if (user != null) {
					user.COMEIN = false;
					cacheArr.push(user)
				}				
				return user;
			}
			//从web列表删除
			var _len:uint = webUsers.length;
			for (var i:uint = 0; i < _len; i++) {
				if (webUsers[i].uid == uid) {
					user=webUsers.splice(i, 1)[0];
					break;
				}
			}			
			//从整个列表删除
			for(i=0;i<_userList.length;i++){
				if (_userList[i].uid == uid) {						
					user = _userList.splice(i, 1)[0];					
					break;
				}
			}	
			
			//补充web列表
			fillWebUser();
			if (user != null) {
				user.COMEIN = true;
				//减少管理员计数
				if (user.m_byUserRule > 0) {				
					adminCount--;				
				}
			}			
			
			return user;
		}
		/**
		 * 增加房间
		 */
		public function addRoom(roomId:Number, RoomPwd:String):void {
			thisRoomID=roomId;
			if (myRoomInfo == null) {
				myRoomInfo = new RoomInfo();
			}
			serverIpUrl=serverIpUrl+roomId;
			myRoomInfo.m_szRoomId = roomId;
			myRoomInfo.m_szRoomPwd = RoomPwd;
			myRoomInfo.loginServerType="roomProx";
		}
		/**
		 * 自己的模型
		 */
		public function get myUserInfo():UserInfo {
			return myUserModel;
		}
		/**
		 * 返回指定用户
		 */
		public function getUser(uid:Number):UserInfo {
			if(uid==0){
				return null;
			}
			var temp:Vector.<UserInfo> = _userList.concat();
			for (var i:int = 0; i < temp.length;i++ ) {
				if (uid == temp[i].uid) {
					return temp[i];
				}
			}
			
			if (isSending) {
				temp = this.cacheArr.concat();
				for (i = 0; i < temp.length; i++) {
					if (temp[i].uid == uid) {
						return temp[i];
					}
				}
			}
			
			return null;
		}
		/**
		 * 增加更新麦上用户模型
		 */
		public function addMicUserModel(micIndex:Number,micState:Number,managerID:Number,micTime:Number,speakUserID:Number,stopSpeakTime:Number,startTime:Number):MicUserInfo{
			//trace(micIndex,micUserList.length,micUserList);
			if(micUserList[micIndex].speakUserID==0){
				micUserList[micIndex]=new MicUserInfo(micIndex);
			}
			micUserList[micIndex].micIndex=micIndex;
			micUserList[micIndex].micState=micState;
			micUserList[micIndex].managerID=managerID;
			micUserList[micIndex].micTime=micTime;
			micUserList[micIndex].speakUserID=speakUserID;
			micUserList[micIndex].stopSpeakTime=stopSpeakTime;
			micUserList[micIndex].startTime=startTime;
			if(speakUserID==0){
				micUserList[micIndex].micName="";
			}else{
				var micUser:UserInfo=getUser(speakUserID);
				if(micUser!=null){
					micUserList[micIndex].micName=micUser.name;
				}
			}			
			return micUserList[micIndex];
		}
		/**
		 * 册除麦上用户
		 */
		public function deleteMicUserModel(micIndex:int):Number{
			var uid:Number=0;
			if(micUserList[micIndex]!=null){
				uid=micUserList[micIndex].speakUserID;
				micUserList[micIndex]=new MicUserInfo(micIndex);
				//micUserList.splice(micIndex,1);
			}
			return uid;
		}
		/**
		 * 查找麦上用户名称
		 */
		public function micUserFindName():Array{
			var ary:Array=new Array();

			for(var i:int=0;i<micUserList.length;i++){
				if(micUserList[i].speakUserID!=0 && micUserList[i].micName==""){//麦上有人没名字
					var micUser:UserInfo=getUser(micUserList[i].speakUserID);
					if(micUser!=null){
						micUserList[i].micName=micUser.name;
						ary.push(micUserList[i].getJsObj());
					}
				}
			}
			return ary;
		}
		/**
		 * 返回用户名称
		 */
		public function getUserName(uid:Number):String {			
			if (uid == 0) {
				return "大家";
			}
			var temp:Vector.<UserInfo> = _userList.concat();
			
			for(var i:int=0;i<temp.length;i++){
				if(temp[i].uid==uid){
					return temp[i].name;
				}
			}
			
			if (isSending) {
				temp = this.cacheArr.concat();
				for (i = 0; i < temp.length; i++) {
					if (temp[i].uid == uid) {
						return temp[i].name;
					}
				}
			}
			
			return "";
		}			
		
		/**
		 * 返回分页用户列表
		 */
		public function getUserList(page:int = 1):Array {			
			var oAry:Array = [];				
			pageIndex = page;
			
			fillWebUser();
			
			oAry = webUserToArrObj();
			
			//this.deailCache();
						
			return oAry;
		}
		/**
		 * 返回管理员列表
		 */
		public function getAdminUserList(page:int=1):Array{
			if(page<=0)page=1;
			var oAry:Array = [];
			var temp:Vector.<UserInfo> = _userList.concat();
			for (var i:int = 0; i < temp.length; i++) {
				try {
					if(temp[i].m_byUserRule>0){
						oAry.push(temp[i].getJsObj());
					}
				}catch (e:Error) {
					
					Log.out("getAdminUserList has Error", e.message)
					continue;
				}
				
			}
			var startIndex:int=(page-1)*userListTotal;
			var endIndex:int=page*userListTotal;
			if(startIndex>=oAry.length)return [];
			if(endIndex>oAry.length)endIndex=oAry.length;
			return oAry.slice(startIndex,endIndex);
		}
		/**
		 *根据UID,用户名查询找用户
		 *@param str:查找的字符
		 *@param type:查找类型 -1:全部查找,0:普通用户,1:管理员,2麦序用户
		 *@param type:查找类型 0:为全部查找 1:管理员,2麦序用户
		 */
		public function findUser(str:String,type:int=-1):Array{
			var uAry:Array = [];
			
			if(type==2){
				for(var j:int=0;j<micXUserIDList.length;j++){
					var user:UserInfo=getUser(micXUserIDList[j]);
					if(user!=null){
						if(user.uid.toString().indexOf(str)!=-1 || user.name.indexOf(str)!=-1){
							uAry.push(user.getJsObj());
						}
					}
				}	
			}else {
				var temp:Vector.<UserInfo> = _userList.concat();
				for(var i:int=0;i<temp.length;i++){
					if(temp[i].uid.toString().indexOf(str)!=-1 || temp[i].name.indexOf(str)!=-1){
						if(type==0){
							//if(userList[i].m_byUserRule<=0)uAry.push(userList[i].getJsObj());
							uAry.push(temp[i].getJsObj());
						}
						if(type==1){
							if(temp[i].m_byUserRule>0)uAry.push(temp[i].getJsObj());
						}
						if(type==-1){
							uAry.push(temp[i].getJsObj());
						}
					}
				}
			}
			return uAry;
		}
		
		
		public function get totalUser():uint{			
			return _userList.length;
		}
		
		public function set totalAdUser(value:uint):void {
			adminCount = value;
		}
		
		public function get totalAdUser():uint{
			return adminCount;
		}
		
		public function get totalMicUser():uint{
			
			return micXUserIDList.length;
		}
		
		public function get userList():Vector.<UserInfo> 
		{
			return _userList;
		}
		
		
		/**
		 * 房间断开
		 */
		public function socketClose():void{
			/*for(var i:int=0;i<userList.length;i++){
				userList[i]=null;
			}*/
			pageIndex=0;
			_userList = new Vector.<UserInfo>();
			webUsers = new Vector.<UserInfo>();
			cacheArr = new Vector.<UserInfo>();
			micXUserIDList = [];			
			this.leaveUsers = new Vector.<Number>();			
			//addUserModel(myUserModel);
		}
		
	}

}