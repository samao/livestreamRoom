package com.guagua.chat.Server 
{
	import com.guagua.events.EventProxy;
	import com.guagua.events.RoomEvent;
	import com.guagua.chat.model.RoomModel;
	//import com.guagua.chat.net.socket.ISocket;
	import com.guagua.utils.ConstVal;
	//import com.guagua.chat.net.socket.ResSocket;
	import com.guagua.chat.net.socket.SecuritySocket;
	//import com.guagua.chat.net.socket.SocketManager;
	//import com.guagua.chat.net.web.WebDataLoader;	
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	

	/**
	 * ...
	 * @author Wen
	 */
	public class ServerMain
	{
		//房间服务器	
		private var res:ResProxy;
        private var cas:RoomProxy;
		private var cqs:CqsProxy;
		private var bsp:BspProxy;
		private var goodsProxy:GoodsProxy;

		//private var webloader:WebDataLoader;
		
		public function ServerMain() 
		{
			//注册JS侦听
			if(ExternalInterface.available){
				//从用户列表中查找用户
				ExternalInterface.addCallback("findUser", roomFindUser);
				//分页用户
				ExternalInterface.addCallback("pageUserList", pageUserList);
				//管理员
				ExternalInterface.addCallback("getAdminUserList",getAdminUserList);
				//设置房间密码
				ExternalInterface.addCallback("setRoomPwd",setRoomPwd);
			}
		}
		
		/**
		 *初始化用户
		 *@param uid :用户ID
		 *@param name :用户名字
		 *@param meck:加密串
		 *@param roomId:房间ID
		 *@param RoomPwd:房间密码
		 *@param wPhotoNum:头像
		 *@param m_wTuyaImage:涂鸦
		 *@param byUserRule:用户状态
		 *@param EquipState:用户装备
		 *@param ClientVer:客户端版本
		 *@param net:网络类型
		 *@param Media:媒体
		 */
		public function initUser(uid:Number = 10000000000, name:String = "wei文asd", meck:String = "9b5142f7d15c32a4404047bc9a845197e0332d620c68f108acf29816a2f523c7", roomId:Number = 500000, RoomPwd:String = "0", wPhotoNum:Number = 10034 , m_wTuyaImage:Number = 0, byUserRule:Number = 0, EquipState:Number = 3097169636835329, ClientVer:int = 29, net:int = 0, Media:Array = null):void {		
			
			RoomModel.getRoomModel().addWebUserIn(uid, name, meck, wPhotoNum, m_wTuyaImage, byUserRule, EquipState, Media,net);		
			RoomModel.getRoomModel().addRoom(roomId, RoomPwd);						
		}
		/**
		 *初始化服务器
		 *@param roomProxyIp : roomProxy IP
		 *@param roomProxyPort:roomProxy 端口
		 *@param wbsIp:游客服务ip
		 *@param wbsPort:游客服务端口
		 */
		public function initServer(roomIp:String = "121.18.236.35", roomPort:uint = 5500,cqsIp:String = "121.17.125.27", cqsPort:uint = 9981,bspIp:String = "192.168.24.178", bspPort:uint = 3000,acsIp:String = "192.168.24.178", acsPort:uint = 3000):void {
			RoomModel.getRoomModel().setIp(roomIp,roomPort,ConstVal.SERVER_TYPE_CAS);
			RoomModel.getRoomModel().setIp(cqsIp,cqsPort,ConstVal.SERVER_TYPE_CQS);
			RoomModel.getRoomModel().setIp(bspIp,bspPort,ConstVal.SERVER_TYPE_BSP);
			RoomModel.getRoomModel().setIp(acsIp,acsPort,ConstVal.SERVER_TYPE_ACS);			
		}
		
		/**
		 * 重新设置ip,port (web2.0弃用)
		 */
		public function regetip(type:String,ip:String,port:uint):void{
			RoomModel.getRoomModel().setIp(ip,port,type);
			switch(type){
				case "cas":
					cas.loginRoomProxy();
					break;
			    case "cqs":
					cqs.loginRoomProxy();
					break;
				case "bsp":
					bsp.loginRoomProxy();
					break;
				case "acs":
					goodsProxy.loginRoomProxy();
					break;
		   
			}
		}
		/**
		 * cas登陆成功
		 */
		private function casLoginOk(e:RoomEvent=null):void {	
			Log.out("Cas连接成功：", RoomModel.getRoomModel().roomProxyIp, RoomModel.getRoomModel().roomProxyPort)
			
			if (res == null) {
				res = new ResProxy();
				res.addEventListener(Event.COMPLETE, resReadyHandler);				
				res.loginResProxy();
							
				goodsProxy=new GoodsProxy();
				goodsProxy.loginRoomProxy();
				
				cqs=new CqsProxy();
				cqs.loginRoomProxy();
				
				bsp=new BspProxy();
				bsp.loginRoomProxy();
			}
		}
		/**
		 * 登陆---cas
		 */
		public function login():void {					
			
			if(cas==null){
				cas=new RoomProxy();
				EventProxy.instance().addEventListener(RoomEvent.Event_Socket_Cas_Login,casLoginOk);
			}			
			
			/*聊天室2.0项目改变cas容错			 
			var webloader:WebDataLoader=WebDataLoader.getInstance();			
			webloader.load()*/			
			
			cas.loginRoomProxy();			
		}
		
		private function resReadyHandler(e:Event):void 
		{
			res.removeEventListener(Event.COMPLETE, resReadyHandler);
			//login();
			//casLoginOk();
			RoomModel.getRoomModel().casAPI.dealVec();
		}
		
		/**
		 * js接口  从模型中查找用户
		 */
		public function roomFindUser(str:String,type:int):Array{
			if(RoomModel==null)return [];
			return RoomModel.getRoomModel().findUser(str,type);
		}
		/**
		 * js接口 分页用户
		 */
		public function pageUserList(page:int=1):Object{
			return {userCount:RoomModel.getRoomModel().totalUser,adminUserCount:RoomModel.getRoomModel().totalAdUser,micUserCount:RoomModel.getRoomModel().totalMicUser,userList:RoomModel.getRoomModel().getUserList(page)};
		}
		/**
		 * js接口 管理员列表
		 */
		public function getAdminUserList(page:int=1):Array{
			return RoomModel.getRoomModel().getAdminUserList(page);
		}
		
		/**
		 * js接口 房间密码
		 */		
		public function setRoomPwd(pwd:String):void{			
			RoomModel.getRoomModel().myRoomInfo.m_szRoomPwd = pwd;			
			if(cas!=null){
				cas.setPwdHandler();
			}
		}
		
	}

}