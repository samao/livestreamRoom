package com.guagua.normal
{
	import com.guagua.events.FAssetsEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.external.*;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	import gs.*;
	import gs.easing.*;
	
	import net.hires.debug.Stats;

	/**
	 * 登场特效主类
	 *@Date:2012-11-1 下午05:42:10	
	 */
	
	public class MainEntry extends Sprite
	{
		/**外部资源管理类*/
		private var fAssets:FAssets;
		/**用户管理类*/
		private var fUserListManager:FUserListManager;
		
		private var isVisible:Boolean;
		
		private var path:URLRequest=new URLRequest();
		private var assets:Loader=new Loader();
		private var assetsReady:Boolean;
		
		private var clipBox:Sprite=new Sprite();
		
		private var mTxt:TextField=new TextField();

		/**停车场按钮*/
		private var parkBut:DisplayObject;
		
		private var isPlaying:Boolean=false;
		
		private var curUser:FUserInfor;
		
		public function MainEntry()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			init();
		}
		
		/**初始化MainEntry数据*/
		private function init():void{
			mTxt.autoSize="left";
			
			fAssets=FAssets.getInstance();
			fUserListManager=FUserListManager.getInstance();	
			
			fAssets.addEventListener(FAssetsEvent.READY,libReadyHandler);
			
			this.addEventListener(Event.ACTIVATE,activeHandler);
			this.addEventListener(Event.DEACTIVATE,this.activeHandler);
			
			if(ExternalInterface.available){			
				ExternalInterface.addCallback("callFlash",onCall);	
				ExternalInterface.call("FlashReady","MainPark is on Stage");	
								
			}
			/*onCall({m_iFuncID:1005,m_iUserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100002,m_szUserName:"光棍无敌1",m_wCarOrder:989895,m_szCar:"奔驰2",m_lCarID:"13821"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100003,m_szUserName:"光棍无敌2",m_wCarOrder:989896,m_szCar:"奔驰2",m_lCarID:"13822"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100006,m_szUserName:"光棍",m_wCarOrder:95,m_szCar:"奔驰",m_lCarID:"13823"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100065,m_szUserName:"光棍无敌1",m_wCarOrder:998,m_szCar:"奔驰2",m_lCarID:"E2"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100073,m_szUserName:"光棍无敌2",m_wCarOrder:9898,m_szCar:"奔驰2",m_lCarID:"E2"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100041,m_szUserName:"棍无",m_wCarOrder:98,m_szCar:"奔驰",m_lCarID:"E2"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100032,m_szUserName:"光棍无敌1",m_wCarOrder:898,m_szCar:"奔驰2",m_lCarID:"E2"})
			onCall({m_iFuncID:1005,m_i64UserNobilityLevel:0,m_iUserVipLevel:0,m_i64UserID:100203,m_szUserName:"光棍无敌2",m_fCarPrice:989898,m_szCar:"奔驰2",m_lCarID:"E2"})*/
			
			//加载资源
			loadAssets();
			
			this.addChild(clipBox);
			//this.addChild(new net.hires.debug.Stats())
			
			//initializeUser(100004)
		}
		
		/**
		 * 资源加载结果
		 * @param event.isReady为加载结果
		 * */
		protected function libReadyHandler(event:FAssetsEvent):void
		{
			//资源加载结果
			if(event.isReady){
				playCarMovie();
			}else{
				if(curUser!=null){					
					gotoPark(curUser)
					curUser=null;
					playCarMovie();
				}				
			}			
		}
		
		/**获取窗口激活状态*/
		protected function activeHandler(event:Event):void
		{
			this.mTxt.text=event.type;	
		}
		
		/**拉伸窗口自适应*/
		protected function resizeHandler(event:Event):void
		{
			parkBut.x=stage.stageWidth;
		}
		
		/**
		 * 初始化客户端id
		 * @param id:用户id
		 * @return 调用成功返回true
		 * */
		public function initializeUser(id:Number):Boolean{
			fUserListManager.client_uid=id;
			return true;
		}
		
		/**加载rsl运行时资源库*/
		private function loadAssets():void
		{
			path.url=ConstVal.ASSETS_PATH;
			var ldrContext:LoaderContext=new LoaderContext(false,ApplicationDomain.currentDomain);			
			assets.contentLoaderInfo.addEventListener(Event.COMPLETE,loadResult);
			assets.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,IoHandler);			
			assets.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			mTxt.text="开始加载资源";
			assets.load(path,ldrContext);
		}
		
		/**加载进度*/
		protected function progressHandler(event:ProgressEvent):void
		{
			trace("资源加载：",event.bytesLoaded+"/"+event.bytesTotal);			
		}
		
		/**未找到资源文件*/
		protected function IoHandler(event:IOErrorEvent):void
		{
			trace("未找到资源库")
			clearEventHandler()		
			if(ExternalInterface.available){
				ExternalInterface.call("onFlashError","没加载到资源")
				//ExternalInterface.call("FlashReady","MainPark is on Stage");			
			}
		}
		
		/**加载完成处理事件*/
		protected function loadResult(event:Event):void
		{
			clearEventHandler()	
			assetsReady=true
			//1.build stage
			buildStage();			
			//2.add click event
			stage.addEventListener(MouseEvent.CLICK,clickHandler,true);
			//stage.addEventListener(MouseEvent.MOUSE_UP,clickHandler)
			stage.addEventListener(Event.RESIZE,resizeHandler);
			//开始进场
			this.mTxt.text="加载完成"
			mTxt.x=50;
			//this.addChild(mTxt);	
			
			//列表不为空就开始播放动画 ；
			if(fUserListManager.hasNext()){
				playCarMovie();
			}
									
		}		
		
		/**鼠标点击冒泡事件*/
		protected function clickHandler(event:MouseEvent):void
		{
			var tar:*=event.target;
			mTxt.appendText(String(tar));
			//屏蔽按钮
			if(tar==MovieClip(fAssets.getAssets("DropFlashDef"))){
				//屏蔽flash登场特效
				trace("屏蔽登场特效");
				if(ExternalInterface.available){
					ExternalInterface.call("dropFlash");
				}
				clipBox.visible=false;
				return
			}
			
			//停车场按钮
			if(tar==MovieClip(fAssets.getAssets("ParkBut"))){
				trace("打开停车场")
				if (ExternalInterface.available)
				{
					//打开停车场
					ExternalInterface.call("OpenPark");
				}
				return
			}
		}
		
		/**初始化舞台元素*/
		private function buildStage():void
		{
			//尾烟特效
			fAssets.addAssets("Hc");				
			var p:DisplayObject=fAssets.getAssets("Hc");
			
			p.x=-10;
			p.y=stage.stageHeight*.5;
			p.scaleX=p.scaleY=.5
			p.visible=false
			MovieClip(p).stop()
			this.addChild(p)	
			
			//屏蔽按钮
			fAssets.addAssets("DropFlashDef");
			var dropFlashBut:DisplayObject=fAssets.getAssets("DropFlashDef");
			dropFlashBut.visible=false;
			MovieClip(dropFlashBut).buttonMode=true;
			//dropFlashBut.width=40;
			MovieClip(dropFlashBut).addEventListener(MouseEvent.MOUSE_OVER,overHandelr);
			MovieClip(dropFlashBut).addEventListener(MouseEvent.MOUSE_OUT,overHandelr);
			this.addChild(dropFlashBut);
			
			//停车场按钮
			addParkBut();
		}
		
		/**鼠标滑入屏蔽按钮效果*/
		protected function overHandelr(event:MouseEvent):void
		{
			switch(event.type){
				case MouseEvent.MOUSE_OVER:
					MovieClip(event.currentTarget).nextFrame();
					break;
				case MouseEvent.MOUSE_OUT:
					MovieClip(event.currentTarget).prevFrame();
					break;
			}
		}
		
		/**初始化停车场按钮*/
		private function addParkBut():void
		{
			fAssets.addAssets("ParkBut");
			parkBut=fAssets.getAssets("ParkBut") as DisplayObject;
			//trace(parkBut.width)
			parkBut.x=stage.stageWidth;
			//parkBut.y=(stage.stageHeight-parkBut.height)*.5;
			//parkBut.visible=false;
			MovieClip(fAssets.getAssets("ParkBut")).buttonMode=true;
			MovieClip(fAssets.getAssets("ParkBut")).addEventListener(MouseEvent.MOUSE_OVER,overHandler,true);
			MovieClip(fAssets.getAssets("ParkBut")).addEventListener(MouseEvent.MOUSE_OUT,overHandler,true);
			this.addChild(parkBut);			
		}
		
		/**停车场按钮鼠标效果*/
		protected function overHandler(event:MouseEvent):void
		{
			if(MovieClip(fAssets.getAssets("ParkBut")).currentFrame>=3){
				return
			}
			switch(event.type){
				case MouseEvent.MOUSE_OVER:
					MovieClip(fAssets.getAssets("ParkBut")).gotoAndStop("over")
					break;
				case MouseEvent.MOUSE_OUT:
					MovieClip(fAssets.getAssets("ParkBut")).gotoAndStop("normal")
					break;
			}
		}
		
		/**播放登场特效动画*/
		private function playCarMovie():void{	
			
			//1.检测列表
			if(fUserListManager.hasNext()){					
				var user:FUserInfor=fUserListManager.getNextUser();					
				var texture:DisplayObject;				
				if(user.m_wCarOrder<ConstVal.MINI_ORDER){
					//显示限制
					trace(user.m_i64UserID,user.m_szUserName,"车辆价格太低，不显示效果")
					gotoPark(user);
					playCarMovie();
					return
				}
				
				//通知客户端显示flash对话框
				if(ExternalInterface.available){
					if(!isVisible){
						trace("队列中有用户，显示flash")
						isVisible=true;
						ExternalInterface.call("showFlash");							
					}									
				}					
				
				//用于后面删除用户模型			
				//资源没好请等待加载
				if(!user.isReady){
					curUser=user;
					fAssets.loadAssets();	
					return
				}				
				
				//parkBut.visible=false;
				
				fAssets.getAssets("DropFlashDef").visible=true
				
				//初始化车辆皮肤
				//没找到资源，建立资源压入hashmap				
				if(!fAssets.hasAssets("L"+user.libMap)){					
					fAssets.addAssets("L"+user.libMap);				
				}	
				texture=fAssets.getAssets("L"+user.libMap);				
				
				texture.y=stage.stageHeight*.5;
				texture.x=-texture.width*.5;				
				
				if(user.m_i64UserID==fUserListManager.client_uid){					
					//播放自己车辆
				}
				user.texture=texture;				
				TweenMax.to(texture,ConstVal.MOVIE_LENGTH/3,{x:texture.width,onComplete:fadeInStage,onCompleteParams:[user,texture]})				
				clipBox.addChild(texture);	
				
				//this.parkBut.visible=false;
				return
			}		
			//2.列表中没有用户了。
			trace("队列列表空了，隐藏flash")			
			this.parkBut.visible=true;
			fAssets.getAssets("DropFlashDef").visible=false;			
			MovieClip(this.parkBut).gotoAndPlay("go");
			MovieClip(this.parkBut).addEventListener(Event.ENTER_FRAME,parkButFrameHandler)			
		}		
		
		/**停车场按钮晃动效果*/
		protected function parkButFrameHandler(event:Event):void
		{
			var tar:MovieClip=event.currentTarget as MovieClip;
			//mTxt.text=this.stage.toString();
			if(tar.currentFrame==tar.totalFrames){
				tar.removeEventListener(Event.ENTER_FRAME,parkButFrameHandler);
				//晃动结束，隐藏flash
				//trace("parkBut is end",isVisible)
				if(ExternalInterface.available){				
					if(isVisible){
						isVisible=false;
						ExternalInterface.call("hideFlash");
					}				
				}
			}
		}
		
		/**
		 * 左侧进入动画
		 * @param arg:用户模型
		 * @param texture:用户皮肤
		 * */
		private function fadeInStage(arg:FUserInfor,texture:DisplayObject):void{
			MovieClip(fAssets.getAssets("Hc")).visible=true;
			MovieClip(fAssets.getAssets("Hc")).gotoAndPlay(2);			
			TweenMax.to(texture,ConstVal.MOVIE_LENGTH*2/3,{x:stage.stageWidth+texture.width*.5,ease:Quad.easeIn,onComplete:onMotionFinished,onCompleteParams:[arg]})
		}
		
		/**一个车整体动画播放完毕*/
		private function onMotionFinished(value:FUserInfor):void{	
			//trace("clipBox:",value.texture)
			clipBox.removeChild(value.texture);
			gotoPark(value);	
			//继续播放下一个
			playCarMovie();
		}	
		
		/**通知客户端用户进入停车场了*/
		private function gotoPark(value:FUserInfor):void{
			//trace("通知C++用户",value.m_szUserName,value.m_lCarID,"进入停车场")
			if(!fUserListManager.isLeave(value.m_i64UserID)){				
				if(ExternalInterface.available){
					var userObj:Object=value.toObject();
					userObj.m_iFuncID=ConstVal.USER_ENTRY;
					ExternalInterface.call("gotoPark",userObj);		
				}		
				//从列表移除用户,从进入列表
				fUserListManager.removeUser(value);
			}else{
				//从离开列表移除用户
				fUserListManager.removeUserFromLeave(value.m_i64UserID);
			}
		}
		
		/**清除资源加载器相关事件*/
		private function clearEventHandler():void{
			assets.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadResult);
			assets.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,IoHandler);
			assets.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
		}
		
		/**
		 * Flash接口控制
		 * @param obj:外部容器传进来的数据对象
		 * @return 调用成功返回 true
		 * */
		public function onCall(obj:Object):Boolean
		{
			switch(Number(obj[ConstVal.m_iFuncID])){
				//用户进入
				case ConstVal.USER_ENTRY:					
					userEntry(obj);
					break;
				//用户离开
				case ConstVal.USER_LEAVE:					
					userLeave(obj);
					break;
				case ConstVal.USER_LIST:
					
					break;
			}			
			return true;
		}
		
		/**
		 * 新用户进入
		 * @param obj:外部容器传进来的数据对象
		 * */
		public function userEntry(obj:Object):void{					
			var user:FUserInfor=new FUserInfor(obj);					
			//如果用户在离开列表移入进入列表
			if(fUserListManager.isLeave(user.m_i64UserID)){
				trace("用户:",user.m_szUserName,user.m_i64UserID,"从离开列表转移到进入列表")
				fUserListManager.moveUserToEntryList(user.m_i64UserID);
			}else{
				fUserListManager.addUser(user);
			}		
			fAssets.insertUser(user);
			this.mTxt.text=user.m_szUserName;
			//联调和发布需要打开激活
			if(!this.isVisible&&assetsReady){
				this.playCarMovie();					
			}			
		}		
		
		/**
		 * 用户离开
		 * @param obj:外部容器传进来的数据对象
		 * */
		public function userLeave(obj:Object):String{			
			var user:FUserInfor=fUserListManager.removeUser(new FUserInfor(obj));
			if(user==null){
				return "用户不存在"
			}
			return fUserListManager.addToLeave(user)
		}
		
		
		/**渲染舞台*/
		public function displayStage():void{
			
		}
	}
}