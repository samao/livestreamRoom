package com.guagua.chat.model 
{
	import com.guagua.chat.model.RoomModel;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Wen
	 */
	public class RoomInfo extends EventDispatcher
	{
		public var m_szRoomId:Number = 232425;
		public var m_szRoomPwd:String = "0";
		//房间是否已经关闭  0:关闭
		public var IsRoomClose:int = 1;
		//是否明星房间  0:不是  1:是
		private var _isStarRoom:int=0;
		//是否登录了房间 0:未登录
		public var isLoginRoom:int=0;
		//登陆模式
		public var loginServerType:String="";//""带表未初始化 ,roomProx,wbs
		//房间状态
		public var state:Number = 0;
		/**房间状态*/
		public var m_lRoomState:Number = 0;
		/**房间属性*/
		public var m_lRoomProperty:Number = 0;
		
		public function RoomInfo() 
		{
			
		}
		/**
		 * //房间属性定义[MAX：31]
		enum enum_room_property
		{
			e_RoomCloseProperty = 0,	       //是否支持关闭房间	
			e_RoomLockProperty = 1,			   //是否支持房间加锁	
			e_RoomHideProperty = 2,			   //是否支持房间隐藏	
			e_RoomFamilyProperty = 3,          //是否家族认证
			e_RoomOnlyVipProperty = 4,         //是否仅允许VIP进房间
			e_RoomGiftProperty = 5,            //是否支持礼物赠送
			e_RoomNoLimitUsersPerIpProperty = 6,  //是否不限制挂号

			e_RoomOnlyRedVipProperty = 7,       // 只有红色vip会员能进房间  (2010 beta1)
			e_RoomChargeProperty=8,             // 是否是可收费房间 (2010 beta1)
			e_RoomPrivVideoProperty = 9,       //是否支持私麦
			e_RoomSelfRechargeProperty = 10,    // 是否支持自助充值

			e_RoomOrderSongProperty = 11,		//是否支持点歌
			e_RoomBroadcastProperty = 12,		//房间是否支持贵族广播
			e_RoomTreasureBoxProperty = 13,		//房间是否支持百宝箱  add lsj 财经2.1
			e_RoomVirtualVideoProperty = 14,	//房间是否支持虚拟大视频	 add lsj 自建房间4.0
			e_RoomExpandPanel = 15,              //房间是否支持扩展面板功能  add lsj 自建房间4.0

			e_RoomBugleStyle = 16,				//房间小喇叭的风格 1为娱乐，0为财经， add lsj 社区5.0
			e_RoomGiftTrackStyle = 17,			//房间礼物跑道的风格 1为娱乐，0为财经， add lsj 社区5.0
			e_RoomGiftCabinetStyle = 18,		//房间礼物柜的风格 1为娱乐，0为财经， add lsj 社区5.0
			e_RoomCheerStyle = 19,				//房间喝彩的风格 1为娱乐，0为财经， add lsj 社区5.0
			e_RoomAnonymousProperty = 20,      //是否是匿名房间(财经2.0 add by peisong 2011.9.9)
			e_RoomStampStyle = 21,				//房间印章的风格 1为娱乐，0为财经， add lsj 社区5.0

			e_RoomVideoProperty = 30,          //是否支持视频
			e_RoomAudioProperty = 31           //是否支持语音
		};

		//房间状态定义[MAX：31]
		enum enum_room_state
		{
			e_RoomCloseState = 0,	  //房间是否关闭
			e_RoomLockState = 1,      //房间是否加锁
			e_RoomHideState = 2,	  //房间是否隐藏
			e_RoomOnlyFamilyState = 3,    //是否认证家族成员（仅家族成员能进）
			e_RoomPubMsgState = 4,    //公聊频道状态
			e_RoomFlowerState = 5,    //是否允许喝彩 
			e_RoomVisitorTextState = 6,   //游客能否发言
			e_RoomMicRollModeState = 7, //排麦方式

			e_RoomVisitorForbitState = 8, //拒绝游客进房间
			e_RoomOnlyVipState = 9, //只有VIP会员能进房间

			e_RoomOnlyRedVipState=10,           // 只有红色vip会员能进房间 (2010 beta1)
			e_RoomFreezeState=11,               // 房间是否冻结 (2010 beta1)
			e_RoomChargeState=12,               // 房间是否收费 (2010 beta1)
			e_RoomOnlyVisitantState=13,         // 房间是否只有贵宾能进房间 (2010 beta1)

			//add by peisong 2010.07.12
			e_RoomTypePrivProperty = 14,         //不同房间类型私有的一个属性位，（财经房间：大视频是否可录制）	

			e_RoomClosePrivVideoState=15,       // 私麦状态(mercury2.0)	1是关闭 0是正常
			e_RoomPluralSongState = 16,			//是否开启复数点歌（新添加的房间状态）
			e_RoomAnonymousState = 17,       //是否开启了匿名功能(财经2.0 add by peisong 2011.9.9)

			e_RoomCloseMicOrderState = 18,  //麦序是否关闭(呱呱3.3 add by zelong 2012.01.19)

			e_RoomStartGradeState = 19,//开始评分状态 1是开始 0是重置，（花儿朵朵项目 add by zelong 2012.04.10）

			e_RoomCloseEnterEffects = 20,//是否关闭汽车进场特效（停车场项目 1是关闭，0是开启，默认为开启）
			e_RoomForbitYellowVipChat = 21,		//禁止黄色vip及其以下用户聊天（扩容2期 add by Zhikun 2012.12.28）

			e_RoomStateCntState,			//房间状态总数（用这个来循环所有房间状态）
		};
		 */
		public function set roomState(data:Number):void{
			state = data;
			isStarRoom = data >> 5 & 0x1;
			IsRoomClose = data & 0x1;
			Log.out("房间状态改变：", state.toString(2));
			Log.out("设置房间状态：", IsRoomClose);
		}
		
		public function get isStarRoom():int 
		{
			return _isStarRoom;
		}
		
		public function set isStarRoom(value:int):void 
		{
			_isStarRoom = value;
			
			RoomModel.getRoomModel().iPlayer.roomStateChange(_isStarRoom);
			
			Log.out("房间献花：",RoomModel.getRoomModel().iPlayer, _isStarRoom);
			
		}
		
	}

}