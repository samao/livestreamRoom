package com.guagua.ui 
{
	import com.greensock.events.TweenEvent;
	import com.guagua.chat.model.FmsManager;
	import com.guagua.events.FmsEvent;
	import com.guagua.chat.model.FmsModel;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.net.handler.room.RoomCmdHandler;
	import com.guagua.events.RtmpEvent;
	import com.guagua.net.RtmpStream;
	import flash.utils.Timer;
	//import flash.events.NetDataEvent;
	//import com.adobe.serialization.json.JSON;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenMax;
	//import filters.FiltersOperation;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.text.TextField;
	//import flash.utils.Timer;
	import com.guagua.events.UIEvent;
	import com.guagua.ui.FlowerDef;
	import com.guagua.utils.ConstVal;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class GuaVideo extends Sprite 
	{
		/**麦上用户*/
		private var _user:UserInfo;
		/**麦序*/
		private var _micIndex:uint;
		/**麦上人名*/
		private var userNameTxt:TextField;
		/**视频*/
		private var videoDef:Video;		
		/**控制条*/
		private var controlBar:UIVideoControl;		
	
		
		/**音频音量*/
		private var soundVolume:SoundTransform;
		
		//ui
		private var nameDefSp:MovieClip;
		private var videoMaskDef:Shape;		
		private var starLevelDef:Sprite;
		private var zoneDef:UserCenter;
		private var loadingDef:VloadIng;
		private var goodsDef:SimpleButton;
		public var flowerDef:FlowerDef;
		private var videoBackgroundBut:MovieClip;
		private var micStatusDef:MicStatusDef;
		private var flowerTxtContainer:Sprite;	
		private var returnNormal:TextField;
		private var onMicDef:OnMicDef;
		private var weChatDef:WeChat;
		
		/**送出花的数量*/
		private var sendFlowerCount:uint = 0;		
		
		/**鲜花数量文本*/
		private var flowerText:TextField;
		/**星星转向*/
		private var ran_dag:Number = 0;		
		/**飞向鲜花总数的花朵*/
		private var flyFlowerDef:FlyFlowerDef;		
		/**鲜花数量*/
		private var _flowerCount:uint = 0;
		/**礼物按钮原始位置*/
		private var goodPoint:Point;
		
		private var bspObject:Object = { };
		
		public var bspIsOk:Boolean = false;
		
		public var streamInCome:Boolean = false;
		
		private var _myFlowerCount:uint = 0;		
		private var mRtmp:RtmpStream;
		
		
		public function GuaVideo() 
		{
			//trace(VideoPlayer)
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		}		
		
		private function onAddedStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
			
			//ui初始化
			nameDefSp = this.getChildByName("nameDef") as MovieClip;
			
			userNameTxt = nameDefSp.getChildByName("nameTxt") as TextField;
			userNameTxt.text = "";
			
			videoDef = this.getChildByName("_video") as Video;				
			controlBar = this.getChildByName("videoContorlBar") as UIVideoControl;
			starLevelDef = nameDefSp.getChildByName("star") as Sprite;
			zoneDef = this.getChildByName("zone") as UserCenter;
			loadingDef = this.getChildByName("loading") as VloadIng;
			flowerDef = this.getChildByName("xhuaBtn") as FlowerDef;
			goodsDef = this.getChildByName("goodsBtn") as SimpleButton;
			videoBackgroundBut = this.getChildByName("videoBut") as MovieClip;
			micStatusDef = this.getChildByName("micStatus") as MicStatusDef;			
			
			flowerTxtContainer = this["TotalFlower"];
			flowerText = this["TotalFlower"]["flowerTxt"];
			
			returnNormal = this["txt"];
			returnNormal.visible = false;
			
			onMicDef = this["onMic"];
			weChatDef = this["chatBut"];
			
			flowerDef.micIndex = micIndex;
			
			goodPoint = new Point(goodsDef.x, goodsDef.y);
					
			
			//默认不显示献花
			roomStateChange(0);			
			
			initEventMap();
			
			//视频遮罩，屏蔽黑边
			videoMaskDef = createMaskDef();
			this.addChild(videoMaskDef);
			videoDef.mask = videoMaskDef
			
			
			
			soundVolume = new SoundTransform();
			
			hideAll();
		}
				
		/**房间状态改变以后调整界面*/
		public function roomStateChange(value:Number):void {
			Log.out("房间状态改变：", value)
			switch (value) {
				case 0:
					//默认情况不可见，非明星不可见
					if (bspObject.m_lStarLevel==null||bspObject.m_lStarLevel <= 0) {
						flowerTxtContainer.visible = false;
						flowerDef.visible = false;
						goodsDef.x = flowerDef.x;
						goodsDef.y = flowerDef.y;						
					}							
					
				break;
				default:
					if (bspObject.m_lStarLevel > 0) {						
						flowerTxtContainer.visible = true;
						flowerDef.visible = true;
						goodsDef.x = goodPoint.x;
						goodsDef.y = goodPoint.y;
						
					}
					
				break
			}
		}
		
		/**初始化事件*/
		private function initEventMap():void 
		{				
			zoneDef.buttonMode = true;
			controlBar.visible = false;
			videoDef.smoothing = true;
			videoDef.deblocking = 4;
			
			//合作版本播放器隐去上麦和空间按钮
			if (ConstVal.PLAYER_TYPE == 1) {
				onMicDef.mouseEnabled = zoneDef.mouseEnabled = false;
				onMicDef.alpha = zoneDef.alpha = 0;
			}
			
			
			this.addEventListener(MouseEvent.MOUSE_OVER, overHandler,true);
			this.addEventListener(MouseEvent.MOUSE_OUT, overHandler,true);			
			
			controlBar.addEventListener(UIEvent.UI_CHANGED, uiChangedHandler);
			controlBar.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			controlBar.addEventListener(MouseEvent.MOUSE_OUT, overHandler);
			
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			zoneDef.addEventListener(MouseEvent.CLICK, gotoZoneHandler);
			
			micStatusDef.addEventListener(MouseEvent.MOUSE_OVER, micOverHandler);
			micStatusDef.addEventListener(MouseEvent.MOUSE_OUT, micOverHandler);
			
			flowerDef.addEventListener(MouseEvent.CLICK, sendFlowersHandler);			
			
		}
		
		public function set rtmp(value:RtmpStream):void
		{
			mRtmp = value;
			
			mRtmp.addEventListener(RtmpEvent.OPEN, rtmpHandler);
			mRtmp.addEventListener(RtmpEvent.RTMP_STREAM_PLAY, rtmpHandler);
			mRtmp.addEventListener(RtmpEvent.USER_INIT, rtmpHandler);
			mRtmp.addEventListener(RtmpEvent.RTMP_AUDIO_CHANGE, rtmpHandler);
			mRtmp.addEventListener(RtmpEvent.FLOWER_DATA, rtmpHandler);
			mRtmp.addEventListener(RtmpEvent.CLOSE, rtmpHandler);
			mRtmp.addEventListener(RtmpEvent.RTMP_UNPUBLISHED, rtmpHandler);
		}
		
		private function rtmpHandler(e:RtmpEvent):void 
		{		
			//trace("%%rtmpHandler:",e.type,e.data)
			switch(e.type)
			{
				case RtmpEvent.OPEN:
					loadingDef.visible = true;
					onMicDef.visible = false;
					break;
				case RtmpEvent.RTMP_STREAM_PLAY:					
					mRtmp.dispatchEvent(new RtmpEvent(RtmpEvent.RTMP_VOLUME, soundVolume));
					videoDef.attachNetStream(e.data);
					loadingDef.visible = false;
					dealProcess();
					break;
				case RtmpEvent.USER_INIT:
					user = e.data;
					break;
				case RtmpEvent.CLOSE:
					closeMic();
					break;
				case RtmpEvent.RTMP_AUDIO_CHANGE:
					audioStatus = e.data;
					break;
				case RtmpEvent.FLOWER_DATA:
					flowerBackCall(e.data);
					break;
				case RtmpEvent.RTMP_UNPUBLISHED:
					videoDef.clear();
					break;
			}
		}
		
		/**视频完成，通知js进度条消失*/
		private function dealProcess():void 
		{
			if (!ConstVal.videoEnabled)
			{
				var fmsMgr:FmsManager = FmsManager.getInstance();
				
				//ErrorToServerMgr.getLocal().addCountStr( "fms:" + fmsMgr.getFms().ip + ":" + fmsMgr.getFms().port + "|" + ConstVal.date  );
				//ErrorToServerMgr.getLocal().add( { errorID:112, serverIp:"", serverPort:0, col1:ConstVal.date.toString() } );
				//trace("视频统计时间",JSON.stringify({ errorID:112, serverIp:"", serverPort:0, col1:ConstVal.date }))
				ConstVal.videoEnabled = true;
				//进度条控制
				if (ExternalInterface.available) ExternalInterface.call("updateProgess",true);
			}
		}		
		
		
		private function sendFlowersHandler(e:MouseEvent):void 
		{
			sendFlowers();
		}
		
		/**买状态鼠标滑动状态*/
		private function micOverHandler(e:MouseEvent):void 
		{
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:
					
					RoomModel.getRoomModel().iPlayer.tipsTool((!micStatusDef.open)?"暂未发言":"正在发言",this.micStatusDef);								
					break;
				case MouseEvent.MOUSE_OUT:
							
					RoomModel.getRoomModel().iPlayer.tipsTool("",this.micStatusDef);
					break;					
			}
		}		
		
		
		/**跳转到个人空间*/
		private function gotoZoneHandler(e:MouseEvent):void 
		{		
			if (user == null) {
				return;
			}	
			Log.out(micIndex,"麦","用户中心；",user.name)
			if(ExternalInterface.available){
				
				try {
					ExternalInterface.call("gotoZone", user.getJsObj());
				}catch (e1:Error) {
					trace("未定义js函数","onData")
				}
			}
		}
		
		private function clickHandler(e:MouseEvent):void 
		{				
			switch(e.target) {
				case videoBackgroundBut:					
					choiceById();	
					break
				case goodsDef:
					controlBar.dispatchEvent(new UIEvent(UIEvent.UI_CHANGED, ConstVal.GIFT));
					break;
				case returnNormal:
					controlBar.dispatchEvent(new Event("openAll"));
					break;
			}
		}
		
		/**和明星聊天*/
		public function chatWithStar():void {
			if (user != null) {
				Log.out("私聊明星:",user.uid, user.name);
				if (ExternalInterface.available) {
					try {
						ExternalInterface.call("pushFlashPri", user.uid, user.name,user.m_i64EquipState);
					}catch (e1:Error) {
						trace("未定义js函数","onData")
					}
					
				}
			}
		}
		
		public function showAllOpen(value:Boolean = false):void {
			returnNormal.visible = value;
		}
		
		/**用户上麦以后请求bsp鲜花总数以后的回调*/
		public function flowerBackCall(value:Object):void {			
			bspObject = value;			
			_flowerCount += value.m_i64TotalFlower;			
			flowerText.text = "" + value.m_i64TotalFlower;
			
			if (user) {				
				if (value.m_i64JoinDate > 0) {
					Log.out("明星上麦", micIndex, user.name, "总数", value.m_i64TotalFlower, "当天", value.m_i64CountFlower);
					roomStateChange(10);	
				}else {
					Log.out("非明星上麦", micIndex, user.name, "总数", value.m_i64TotalFlower, "当天", value.m_i64CountFlower);	
					roomStateChange(0);	
				}	
			}
			showStarLevel()
			
			this.bspIsOk = true;
			//Log.out(JSON.stringify(bspObject))
					
		}
		
		
		
		/**视频控制集合*/
		private function uiChangedHandler(e:UIEvent):void 
		{
			switch(e.cmd) {
				case ConstVal.GIFT:
					sendGoods();
					break;
				case ConstVal.FLOWER:
					sendFlowers();
					break;
				case ConstVal.CLOSE_VIDEO:
					videoDef.visible = false;
					break;
				case ConstVal.OPEN_VIDEO:
					videoDef.visible = true;
					break;
				case ConstVal.CLOSE_AUDIO:
					break;
				case ConstVal.OPEN_AUDIO:
					break;
				case ConstVal.SOUND_CHANGE:
					volume = controlBar.volume;
					break;
			}		
			
			returnNormal.visible=controlBar.allClosed
			
		}		
		
		/**点击视频选中麦上用户*/
		private function choiceById():void {
			//选中麦上用户
			if (user == null) {
				return;
			}				
			
			Log.out(micIndex,"麦","选中用户:",user.uid, user.name,user.userLevel,bspObject.m_lStarLevel);
			//Log.out("点击用户",user.uid,user.name);		
			if (ExternalInterface.available) {
				try {
					ExternalInterface.call("choiceById", user.uid,user.name);
				}catch (e1:Error) {
					trace("未定义js函数","onData")
				}
				
			}
		}
		
		/**设置用户自己鲜花数*/
		public function set myFlowerCount(value:uint):void {
			_myFlowerCount = value;
			flowerDef.flowerCount = _myFlowerCount;
			
			if (_myFlowerCount == 0) {
				flowerDef.status = FlowerStatus.FLOWER_EMPTY;				
			}else if(_myFlowerCount==ConstVal.MAX_FLOWERS_LIMITED) {
				flowerDef.status = FlowerStatus.FLOWER_FULL;				
			}else {
				flowerDef.status = FlowerStatus.FLOWER_GETTING;
			}
		}
		
		
		/**送明星花*/
		private function sendFlowers():void {				
			
			if (user == null) {
				return;
			}			
			
			if (RoomModel.getRoomModel().myUserModel.isGuest) {
				Log.out("游客不允许献花");
				
				if (ExternalInterface.available) {
					ExternalInterface.call("onLogin");
				}
				
				return
			}
			
			Log.out(micIndex, "麦", "送花：", user.name, ConstVal.FLOWERS);	
			
			//ConstVal.FLOWERS = 10;
			//ConstVal.MAX_SEND_FLOWERS = 1;
			if (sendFlowerCount > 0) {
				//正在播放动画
				return;
			}
			//送花
			if (ConstVal.FLOWERS>0&&(ConstVal.FLOWERS >= ConstVal.MAX_SEND_FLOWERS)) {
				
				sendFlowerCount = ConstVal.MAX_SEND_FLOWERS==0?ConstVal.FLOWERS:ConstVal.MAX_SEND_FLOWERS;
				
				ConstVal.FLOWERS = ConstVal.FLOWERS - ConstVal.MAX_SEND_FLOWERS;
				ConstVal.FLOWERS = ConstVal.MAX_SEND_FLOWERS == 0?0: Math.max(0, ConstVal.FLOWERS);
				
				
				
				RoomModel.getRoomModel().casAPI.OperateOtherUser(user.uid, 18, sendFlowerCount);
				
				flyFlowerAnimation();
				
				if (ExternalInterface.available){
					//ExternalInterface.call("sendFlowers", ConstVal.FLOWERS);
					Log.out("明星鲜花：restFlowers", ConstVal.FLOWERS);
					try {
						ExternalInterface.call("restFlowers", ConstVal.FLOWERS);
					}catch (e1:Error) {
						trace("未定义js函数","onData")
					}
				
					
				}
			}else if ((ConstVal.FLOWERS < ConstVal.MAX_SEND_FLOWERS) || ConstVal.FLOWERS == 0) {
				//Log.out("明星献花：你没有积攒够发送数量的鲜花。")
				if (ExternalInterface.available) {
					Log.out("明星献花：你没有积攒够发送数量的鲜花。")
					
					try {
						ExternalInterface.call("sendFlowersFail", "你没有积攒够发送数量的鲜花。");
					}catch (e2:Error) {
						trace("未定义js函数","onData")
					}
				
				}
			}
			flowerDef.efDef.visible = (flowerDef.status != FlowerStatus.FLOWER_EMPTY&& ConstVal.FLOWERS >= ConstVal.MAX_SEND_FLOWERS);
		}
		
		/**鲜花飞向左上角的动画*/
		private function flyFlowerAnimation():void 
		{
			if (sendFlowerCount <= 0) {
				return;
			}
			
			flyFlowerDef = new FlyFlowerDef();
			flyFlowerDef.x = flowerDef.x;
			flyFlowerDef.y = flowerDef.y;
			ran_dag = Math.atan2(flowerTxtContainer.y - flowerDef.y, flowerTxtContainer.x - flowerDef.x);			
			
			this.addChild(flyFlowerDef);
			
			TweenMax.to(flyFlowerDef,1, { x:flowerTxtContainer.x, y:flowerTxtContainer.y, scaleX:.6,scaleY:.6, ease:Cubic.easeInOut,onComplete:animationComplete,onCompleteParams:[flyFlowerDef], onUpdateListener:processHandler} );			
		}
		
		/**清理鲜花动画，回收垃圾*/
		private function animationComplete(value:FlyFlowerDef):void 
		{
			//释放内存占用
			//TweenMax.pauseAll();
			//TweenMax.killAll();	
			TweenMax.killTweensOf(value);
			
			this.removeChild(value);
			
			var flowerBoomDef:FlowerBoom = new FlowerBoom();
			flowerBoomDef.x = flowerTxtContainer.x;
			flowerBoomDef.y = flowerTxtContainer.y;
			flowerBoomDef.scaleX = flowerBoomDef.scaleY = .3;
			this.addChild(flowerBoomDef);
			
			sendFlowerCount--;
			flyFlowerAnimation();
		}
		
		/**飞鲜花时候，后面的星光*/
		private function processHandler(e:TweenEvent):void 
		{		
			if (StarDef.count > 5) {
				
				return;
			}
			var starDef:MovieClip = new StarDef();
			starDef.rotation = ran_dag * 180 / Math.PI + 180;			
			
			
			starDef.x = flyFlowerDef.x;
			starDef.y = flyFlowerDef.y;			
					
			this.addChild(starDef);			
		}
		
		
		/**送明礼物*/
		private function sendGoods():void {	
			if (user == null) {
				return;
			}
			Log.out(micIndex,"麦","送礼物：",user.name)
			if (ExternalInterface.available) {
				try {
					ExternalInterface.call("sendGoods", user.getJsObj());
				}catch (e1:Error) {
					trace("未定义js函数", "onData")
				}				
			}
		}
		
		/**控制音量*/
		public function set volume(value:Number):void {
			//trace("音量：", value);
			soundVolume.volume = value;
			if (mRtmp) {
				mRtmp.dispatchEvent(new RtmpEvent(RtmpEvent.RTMP_VOLUME, soundVolume));
			}
		}
		
		
		private function overHandler(e:MouseEvent):void 
		{					
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:
					
					if (this.user != null) {						
						controlBar.visible = true;
						nameDefSp.visible = false;	
					}
					
					break;
				case MouseEvent.MOUSE_OUT:
					if (this.user != null) {						
						controlBar.visible = false;
						nameDefSp.visible = true;
					}
										
					break;
			}			
			
			//Log.out("e.target",e.target.name,e.currentTarget.name);
			
			//私聊
			if (e.target==this.weChatDef) {
				if (e.type == MouseEvent.MOUSE_OVER) {
					RoomModel.getRoomModel().iPlayer.tipsTool("私聊", this.weChatDef);
				}else {
					RoomModel.getRoomModel().iPlayer.tipsTool("", this.weChatDef);
				}
				e.stopPropagation();
			}
			
			
			//送礼物
			if (e.target == this.goodsDef) {
				if (e.type == MouseEvent.MOUSE_OVER) {
					RoomModel.getRoomModel().iPlayer.tipsTool("赠送礼物", this.goodsDef);
				}else {
					RoomModel.getRoomModel().iPlayer.tipsTool("", this.goodsDef);
				}
				e.stopPropagation();
			}			
			
			//打开视频
			if ((e.target is SimpleButton)&&SimpleButton(e.target).name.indexOf("Video")>=0) {
				if (e.type == MouseEvent.MOUSE_OVER) {
					RoomModel.getRoomModel().iPlayer.tipsTool("开关视频", SimpleButton(e.target));
				}else {
					RoomModel.getRoomModel().iPlayer.tipsTool("", SimpleButton(e.target));
				}
			}
			
			//打开音频
			if ((e.target is SimpleButton)&&SimpleButton(e.target).name.indexOf("Audio")>=0) {
				if (e.type == MouseEvent.MOUSE_OVER) {
					RoomModel.getRoomModel().iPlayer.tipsTool("开关音频", SimpleButton(e.target));
				}else {
					RoomModel.getRoomModel().iPlayer.tipsTool("", SimpleButton(e.target));
				}
			}
		}	
		
		
		
		private function set audioStatus(bool:Boolean):void
		{
			micStatusDef.open = bool;
		}
		
		
		/**关闭麦上用户视频*/
		public function closeMic():String {
			try {			
				Log.out(micIndex, "麦", "用户下麦了")
				flowerText.text = "";
				userNameTxt.text = "";
				//controlBar.visible = false;
				//zoneDef.visible = false;				
				
				bspObject = { };
				
				this.videoDef.clear();
				_user = null;
				
				hideAll()
				
				_flowerCount = 0;
				flowerText.text = "" + _flowerCount;
				roomStateChange(0);				
				
			}catch (e:Error) {
				Log.out("closeMic:", e.message);
				return "下麦失败"
			}
			return "下麦成功";
		}
		
		/**下麦隐藏按钮*/
		private function hideAll():void {
			loadingDef.visible = false;
			controlBar.visible = false;
			zoneDef.visible = false;
			goodsDef.visible = false;
			flowerDef.visible = false;
			micStatusDef.visible = false;
			weChatDef.visible = false;
			micStatusDef.open = false;
			
			starLevelDef.visible = false;					
			starLevelDef.graphics.clear();
			
			onMicDef.visible = onMicDef.mouseEnabled = false;
			onMicDef.alpha = 0;
			
			if (ConstVal.PLAYER_TYPE != 1) {
				onMicDef.visible = onMicDef.mouseEnabled = true;
				onMicDef.alpha = 1;
			}
		}		
		
		
		/**获取当前麦上用户*/
		public function get user():UserInfo 
		{
			return _user;
		}
		
		/**
		 * 当前麦上用户设置
		 * @param value:UserInfo 用户数据模型
		 * */
		public function set user(value:UserInfo):void 
		{
			try {	
				
				if (_user) {
					closeMic();
				}
				
				_user = value;					
				userNameTxt.text = user.name;
				/*//明星等级标识
				if (user.userLevel > 0) {
					starLevelDef.visible = true;
					//starLevelDef.gotoAndStop(user.userLevel);
					//Log.out("ico", ConstVal.BITMAPDATA, user.userLevel)
					
					starLevelDef.graphics.lineStyle(0, 0, 0);
					
					starLevelDef.graphics.beginBitmapFill(ConstVal.BITMAPDATA,new Matrix(1,0,0,1,-uint((user.userLevel-1)/10)*ConstVal.ICO_WIDTH,-((user.userLevel-1)%10)*ConstVal.ICO_HEIGHT))
		
					starLevelDef.graphics.drawRect(0,0,ConstVal.ICO_WIDTH,ConstVal.ICO_HEIGHT);
				
					starLevelDef.graphics.endFill();
				}	*/
				showStarLevel()
				//userNameTxt.x = starLevelDef.visible?starLevelDef.width + starLevelDef.x:starLevelDef.x;
				//controlBar.visible = true;
				
				//空间标识
				zoneDef.visible = true;
				goodsDef.visible = true;
				micStatusDef.visible = true;
				onMicDef.visible = false;
				weChatDef.visible = true;				
				
			}catch (e:Error) {
				Log.out("上麦：", e.message);
			}
		}
		
		/**明星等级显示*/
		private function showStarLevel():void
		{
			starLevelDef.graphics.clear();
			starLevelDef.visible = false;			
					
			//明星等级标识
			if (bspObject.m_lStarLevel > 0&&user!=null) {
				starLevelDef.visible = true;				
					
				starLevelDef.graphics.lineStyle(0, 0, 0);
					
				starLevelDef.graphics.beginBitmapFill(ConstVal.BITMAPDATA,new Matrix(1,0,0,1,-uint((bspObject.m_lStarLevel-1)/10)*ConstVal.ICO_WIDTH,-((bspObject.m_lStarLevel-1)%10)*ConstVal.ICO_HEIGHT),false,true)
		
				starLevelDef.graphics.drawRect(0,0,ConstVal.ICO_WIDTH,ConstVal.ICO_HEIGHT);
				
				starLevelDef.graphics.endFill();
			}	
				
			userNameTxt.x = starLevelDef.visible?starLevelDef.width + starLevelDef.x:starLevelDef.x;
		}
		
		/**获取麦序*/		
		public function get micIndex():uint 
		{
			return _micIndex;
		}
		/**设置麦序*/
		public function set micIndex(value:uint):void 
		{
			_micIndex = value;	
			flowerDef.micIndex = _micIndex;
			weChatDef.mic = micIndex;
		}		
		
		/**增加麦上鲜花数*/
		public function set addFlower(value:uint):void 
		{
			_flowerCount += value;
			flowerText.text = "" + _flowerCount;
		}		
		
		/**遮罩video*/
		private function createMaskDef():Shape {
			var sp:Shape = new Shape();
			sp.graphics.beginFill(0x343434, 0);
			sp.graphics.drawRect(-videoBackgroundBut.width*.5, -videoBackgroundBut.height*.5, videoBackgroundBut.width, videoBackgroundBut.height);
			sp.graphics.endFill();
			return sp;
		}
	}

}