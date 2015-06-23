package com.guagua.ui 
{	
	import com.adobe.crypto.MD5;
	import com.greensock.easing.Sine;
	import com.greensock.TweenMax;
	import com.guagua.chat.model.FmsManager;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.chat.net.handler.bsp.BspCmdHandler;
	import com.guagua.chat.net.handler.room.RoomCmdHandler;
	import com.guagua.chat.util.Operation;
	import com.guagua.debug.Debuger;
	import com.guagua.events.FmsEvent;
	import com.guagua.net.RtmpStream;
	import com.guagua.debug.Monitor;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;	
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	
	import com.guagua.interfaces.IPlayer;
	
	import com.guagua.utils.ConstVal;
	
	import com.guagua.chat.CommServer;
	import com.guagua.chat.model.RoomModel;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class MainVideoPlayer extends MovieClip implements IPlayer
	{
		/**通讯集成实例*/
		private var commServer:CommServer;
		
		/**麦上用户hashMap*/
		private var micDic:Dictionary = new Dictionary();
		
		/**播放器默认版本，数据来自js，用来强制用户更新版本*/
		private var playerVersion:String = "20130909 debug";			
		
		/**房间献花状态检测*/
		private var roomStateTimer:Timer;
		
		private var roomStateValue:Number = -1;
		
		private var _myFlowerCount:uint = 0;
		
		private var tips:TipDef = new TipDef();
		
		private var status:Monitor;
		/**Init data*/
		private var data:Object = { };
		
		private var richTipsDef:RichTips;
		
		private var rtmpVec:Vector.<RtmpStream> = new Vector.<RtmpStream>();
		private var debuger:Debuger;
		/**日志密码.guagua*/
		private var debugPWD:String = "8eb01d7627eb92d0b8d3168aa287d6b0";
		private var debugDef:Sprite;
		private var debugTxt:TextField;
		
		public function MainVideoPlayer() 
		{			
			this.addFrameScript(0, frame0);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedStage);			
		}	
		
		private function frame0():void
		{
			Security.allowDomain("*");
			//this.visible = false;
			stop();
		}
		
		private function onAddedStage(e:Event):void 
		{
			if (commServer)
			{
				return;
			}
			removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);			
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.quality = StageQuality.BEST;			
			//生成日志文本
			createDebugInfo();				
			//界面初始化
			richTipsDef = this.getChildByName("richTips") as RichTips;	
			tips.visible = false;	
			RoomModel.getRoomModel().iPlayer = this;						
			
			//debug模式下功能			
			if (ConstVal.DEBUG_MODE) {	
				//debug模式
				
				debuger = new Debuger();	
				debuger.addEventListener(Event.COMPLETE, beginDataReadyHandler,false,0,true);
				//debuger.loadRoomId();
				//stage.addEventListener(MouseEvent.CLICK, click);
				this.addChild(new DebugUI(enter));
				this["connectStatus"].visible = false;
			}			
			
			if (ExternalInterface.available) {				
				ExternalInterface.addCallback("setMaxSendFlowers", setMaxSendFlowers);				
			}			
			//加载明星等级图片；
			loadStarAssetsLib();
			
			var fmsmgr:FmsManager = FmsManager.getInstance();
			fmsmgr.addEventListener(FmsEvent.FMS_READY, loginHandler,false,0,true);			
			//通信组件
			commServer = CommServer.getInstance();			
			//获取URL数据
			getURLParam();
			//生成鼠标右键菜单
			hideMenu();
			//进度条控制
			if (ExternalInterface.available) ExternalInterface.call("updateProgess",false);
		}	
		
		private function enter(rid:String):void
		{
			debuger.loadWebData(rid);
			this["connectStatus"].visible = true;
		}
		
		/**获取flashVars和URL传入参数*/
		private function getURLParam():void
		{
			
			try {
				if(this.loaderInfo.parameters.v!=null){
					playerVersion = String(loaderInfo.parameters.v);
				}				
				if (this.loaderInfo.parameters.hezuo != null) {
					ConstVal.PLAYER_TYPE = Number(this.loaderInfo.parameters.hezuo);
					Log.out("合作版本播放器：", ConstVal.PLAYER_TYPE);
				}
			}catch (e:Error) {
				Log.out("getURLParam:", e.message);
			}	
			Log.out("getURLParam:", playerVersion, ConstVal.PLAYER_TYPE);
		}
		
		/**
		 * 生成日志文本
		 * */
		private function createDebugInfo():void 
		{
			debugDef = this["debugMc"] as Sprite;
			
			debugTxt = new TextField();
			debugTxt.width = stage.stageWidth - 40;
			debugTxt.height = stage.stageHeight - 30;
			debugTxt.x = 20;
			debugTxt.wordWrap = true;
			debugTxt.multiline = true;
			
			var tf:TextFormat = new TextFormat();
			tf.font = "宋体";
			tf.size = 12;
			debugTxt.defaultTextFormat = tf;
			
			debugDef.addChild(debugTxt);
			
			RoomModel.getRoomModel().debugAPI = debugTxt;
			
			var inText:TextField = new TextField();
			inText.type = TextFieldType.INPUT;
			inText.displayAsPassword = true;
			inText.autoSize = "left";
			inText.maxChars = 10;
			inText.x = stage.stageWidth * .5;
			inText.defaultTextFormat = tf;
			
			debugTxt.visible = false;
			debugTxt.backgroundColor = 0xffffff;
			
			debugTxt.y = inText.height;
			
			debugDef.addChild(inText);
			
			inText.addEventListener(Event.CHANGE, changeHandler);
		}
		
		private function changeHandler(e:Event):void 
		{
			var text:TextField = e.target as TextField;
			
			if (MD5.hash(text.text) == debugPWD)
			{
				//trace("密码正确");	
				debugTxt.visible = true;
				debugTxt.background = true;				
			}else {
				debugTxt.background = false;
				debugTxt.visible = false;
			}
			text.x = stage.stageWidth * .5 - text.width * .5;
		}
		
		/**
		 * CAS登录成功执行FmsEvent.FMS_READY事件
		 * */
		private function loginHandler(e:FmsEvent):void 
		{
			var fmsmgr:FmsManager = e.target as FmsManager;
			fmsmgr.removeEventListener(FmsEvent.FMS_READY, loginHandler);
			for (var i:uint = 0; i < 3; i++)
			{
				var rtmp:RtmpStream = new RtmpStream(i)
				rtmp.open();
				rtmpVec.push(rtmp);
			}
		}
		
		private function click(e:MouseEvent):void{			
			//RoomModel.getRoomModel().casAPI.loginOut();
			//stage.removeEventListener(MouseEvent.CLICK, click);			
		}
		
		/**加载外部ico资源*/
		private function loadStarAssetsLib():void 
		{
			var url:URLRequest = new URLRequest(ConstVal.STAR_ICO_URL);
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, starIcoHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, starIcoHandler);
			loader.load(url);
		}
		
		private function starIcoHandler(e:Event):void 
		{
			switch(e.type) {
				case Event.COMPLETE:
					var bitMap:Bitmap=e.target.content;
					ConstVal.BITMAPDATA = bitMap.bitmapData;
					break;
				case IOErrorEvent.IO_ERROR:
					Log.out("没找到外部starICO");
					break;
			}
			(e.target as LoaderInfo).removeEventListener(IOErrorEvent.IO_ERROR, starIcoHandler);		
			(e.target as LoaderInfo).removeEventListener(Event.COMPLETE, starIcoHandler);			
		}
		
		
		/**
		 * 网页js调用接口,设置一次发送多少鲜花
		 * @param value:Number
		 * */
		public function setMaxSendFlowers(value:Number):void 
		{
			Log.out("js设置鲜花数：",value)
			ConstVal.MAX_SEND_FLOWERS = value > ConstVal.MAX_FLOWERS_LIMITED?ConstVal.MAX_FLOWERS_LIMITED:value;
			richTipsDef.reflush();
		}
		
		/**获取当前视频方案，视频ui实例*/
		private function initVideoDef():void {
			micDic = new Dictionary();
			for (var i:uint = 0; i < 3; i++) {
				micDic["mic" + i] = this.getChildByName("micVideo" + (i+(this.currentFrame-2)*3)) as GuaVideo;
				GuaVideo(micDic["mic" + i]).micIndex = i;
				
				rtmpVec[i].videoSkin = GuaVideo(micDic["mic" + i]);
			}
			
			if (roomStateTimer == null) {
				roomStateTimer = new Timer(500);
				roomStateTimer.addEventListener(TimerEvent.TIMER, roomStateHandler,false,0,true);
				roomStateTimer.start();	
			}		
			this.myFlowerCount = 0;				
		}		
		
		
		private function beginDataReadyHandler(e:Event):void 
		{
			data=Debuger(e.target).webObj
			debuger.removeEventListener(Event.COMPLETE, beginDataReadyHandler);
			debuger = null;
			commServer.debug(data);
		}
		
		/**自定义右键菜单*/
		private function hideMenu():void
		{
			if (Operation.getOperation().compareVersion([10, 2, 0, 0]))
			{
				Log.out("支持右键屏蔽：关闭右键","最低版本10.2.0.0");
				//this.stage.addEventListener(MouseEvent.RIGHT_CLICK, function():void { } );
			}
			var menu:ContextMenu=new ContextMenu();			
			menu.hideBuiltInItems();			
			var VmenuItem:ContextMenuItem = new ContextMenuItem("VERSION:" + playerVersion, false, false);	
			var LogMenuItem:ContextMenuItem = new ContextMenuItem("INF:"+Capabilities.version,false,true);
			LogMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,selectHandler);
			menu.customItems.push(VmenuItem,LogMenuItem);
			this.contextMenu=menu;
		}
		
		private function selectHandler(e:ContextMenuEvent):void 
		{
			if (status == null) {
				status = new Monitor();
				this.addChild(status);
			}else {
				this.removeChild(status);
				status = null;
			}
		}
		
		/**显示鲜花tips*/
		public function showFlowerTips(bool:Boolean,mic:uint):void {			
			if (this.currentFrame <= 2) {
				return;
			}			
			richTipsDef.reflush();			
			var guaVideo:GuaVideo = GuaVideo(micDic["mic" + mic]);			
			var point:Point = new Point(guaVideo.flowerDef.x,guaVideo.flowerDef.y);
			localToGlobal(point);
			richTipsDef.show(bool);			
			if (bool) {
				richTipsDef.alpha = 0;
				TweenMax.to(richTipsDef, .3, { x:point.x + guaVideo.x, alpha:1,ease:Sine.easeInOut } );
			}
		}
		
		/**
		 * tip提示信息
		 * @param value:String提示信息，host:DisplayObject点击的按钮,subHost:DisplayObject按钮内部用于定位原件
		 * */
		public function tipsTool(value:String,host:DisplayObject=null,subHost:DisplayObject=null):void {
			if (value == "") {
				tips.text = "";
				tips.visible = false;				
				//host.parent.removeChild(tips);
				return;
			}
			tips.text = value;	
			
			var sonHost:DisplayObject = subHost == null?host:subHost;
			
			var point:Point = new Point(host.x, host.y - sonHost.height * .5 - tips.minHeight - 3);
			host.localToGlobal(point);		
			//Log.out("提示点：",tips.height,tips.minHeight);
			tips.x = point.x;
			tips.y = point.y;
			tips.visible = true;
			
			host.parent.addChild(tips);			
		}
		
		/**和明星聊天*/
		public function chatWithStar(mic:uint):void {
			GuaVideo(micDic["mic" + mic]).chatWithStar();
		}
		
		/**显示全部打开按钮*/
		public function showAllOpen(mic:uint, value:Boolean = false):void {
			GuaVideo(micDic["mic" + mic]).showAllOpen(value);
		}
		
		/**房间状态改变*/
		public function roomStateChange(value:Number):void {
			roomStateValue = value;				
			if (roomStateTimer == null) {
				roomStateTimer = new Timer(500);
				roomStateTimer.addEventListener(TimerEvent.TIMER, roomStateHandler);
				roomStateTimer.start();	
			}
		}
		
		private function roomStateHandler(e:TimerEvent):void 
		{
			if (roomStateTimer==null&&this.roomStateValue==-1) {
				return;
			}
			
			for (var i:uint = 0; i < 3; i++) {
				if (GuaVideo(micDic["mic" + i]) != null) {
					GuaVideo(micDic["mic" + i]).roomStateChange(roomStateValue);
				}				
			}
			
			roomStateTimer.stop();
			roomStateTimer.removeEventListener(TimerEvent.TIMER, roomStateHandler);
			roomStateTimer = null;
		}
		
		/**设置用户自己鲜花数*/
		public function set myFlowerCount(value:uint):void {			
			_myFlowerCount = value;
			this.richTipsDef.reflush();
			
			for each(var i:GuaVideo in micDic) {
				i.myFlowerCount = value;
			}
		};
		
		/**初始化舞台*/
		public function initStage():void {
			
		}		
		
		
		/**献明星花*/
		public function addFlower(uid:Number, flowerCount:uint):void {
			//trace("MainVideoPlayer",uid,flowerCount)
			for (var i:uint = 0; i < 3; i++) {
				if(GuaVideo(micDic["mic" + i])!=null&&GuaVideo(micDic["mic" + i]).user != null&&GuaVideo(micDic["mic" + i]).user.uid==uid) {
					GuaVideo(micDic["mic" + i]).addFlower = flowerCount;
					break;
				}
			}
		}
		
		/**视频方案*/
		public function videoStyle(value:uint):void {	
			if (ExternalInterface.available) {
				Log.out("视频背景方案：", value);
				try {
					ExternalInterface.call("setVideoBackgroundSkin",value)
				}catch (e:Error) {
					trace("未定义js函数","onData")
				}
				
			}
			//trace("视频背景方案：",value);
			this.gotoAndStop(value+1);
			//this.visible = true;
			initVideoDef();
			
			/*status=new Stats()
			this.addChild(status);*/			
		}
		
		/**用户上麦*/
		public function addMicUser(user:UserInfo, mic:uint):String {			
			if (user == null) {
				return "失败";
			}
			try {
				Log.out(mic, "用户上麦", user.uid,user.name)
				//GuaVideo(micDic["mic" + mic]).user = user;
				rtmpVec[mic].open();
				rtmpVec[mic].user = user;
				
				GuaVideo(micDic["mic" + mic]).bspIsOk = false;			
			}catch (e:Error) {
				Log.out("addMicUser失败:", e.message);
				return "上麦失败"
			}
			
			return "上麦成功";
		}		
		
		
		/**用户下麦*/
		public function delMicUser(user:UserInfo, mic:uint):String {			
			try {	
				if (rtmpVec[mic])
				{
					rtmpVec[mic].close();
				}	
				
				if (user != null) {
					Log.out(mic, "用户下麦", user.uid,user.name)
				}							
				
			}catch (e:Error) {
				Log.out("delMicUser失败:", e.message);				
				return "下麦失败";
			}
			return "下麦成功";
		}
		
		/**关闭所有麦*/
		public function delAllMicUser():String {
			Log.out("您被踢出房间，通道全部关闭！");
			for (var i:uint = 0; i < 3; i++) {				
				delMicUser(GuaVideo(micDic["mic" + i]).user, i);				
			}
			return "您被踢出房间，通道全部关闭！"
		}
	}

}