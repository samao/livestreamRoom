package com.guagua.net 
{
	import com.guagua.chat.model.FmsManager;
	import com.guagua.chat.model.RoomModel;
	import com.guagua.chat.model.UserInfo;
	import com.guagua.events.FmsEvent;
	import com.guagua.events.RtmpEvent;
	import com.guagua.ui.GuaVideo;
	import com.guagua.utils.ConstVal;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	//import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class RtmpStream extends EventDispatcher 
	{
		/**事件map*/
		private var eventMap:Vector.<RtmpEvent> = new Vector.<RtmpEvent>();
		/**接收视频流ui*/
		private var video:GuaVideo;
		/**上麦用户*/
		private var _user:UserInfo;
		
		private var netConn:NetConnection;
		
		private var videoStream:NetStream;
		
		private var audioStream:NetStream;
		/**麦号*/
		private var _micIndex:uint = 0;
		/**fms服务器管理器引用*/
		private var fmsMgr:FmsManager;
		
		/**请求fms列表计时*/
		private var timer:Timer = new Timer(250);
		
		/**流连接状态*/
		private var status:String = RtmpEvent.CLOSE;
		
		/**音频音量*/
		private var volume:SoundTransform = new SoundTransform();		
		
		/**
		 * 间隔1s 功能：1.监测音频状态 2.检测流状态 3.检测网络状态
		 * */
		private var netWatcher:Timer = new Timer(1000);	
		
		/**监测播放过程中断流情况key*/
		private var bufferKey:Boolean = false;
		/**当bufferKey为true时候开始计数，单位秒*/
		private var bufferEmptyTimer:uint = 0;
		
		/**视频帧频*/
		private var _fps:uint = 30;
		/**初始化接收流标识*/
		private var streamInCome:Boolean;
		
		/**用户关闭视频标识*/
		private var unPublishedTag:Boolean = false;
		
		/**
		 * 组合NetConnection和NetStream
		 * @param mic:uint 麦号
		 * */
		public function RtmpStream(mic:uint) 
		{
			_micIndex = mic;
			
			fmsMgr = FmsManager.getInstance();
			
			this.addEventListener(RtmpEvent.RTMP_VOLUME, volumeHandler);
			
			netWatcher.addEventListener(TimerEvent.TIMER, watcherHandler, false, 0, true);
			
		}		
		
		private function watcherHandler(e:TimerEvent):void 
		{
			//音频状态
			if (audioStream && audioStream.info)
			{
				execute(new RtmpEvent(RtmpEvent.RTMP_AUDIO_CHANGE, audioStream.info.currentBytesPerSecond > 0));				
			}			
			
			if (videoStream&&!streamInCome)
			{
				streamInCome = ((videoStream != null && (videoStream.info.videoBufferLength) > 0));
				
				if (netWatcher.currentCount==10&&!streamInCome) {						
					try {
						if (videoStream != null && videoStream.info != null) {
							Log.out(micIndex,"麦","异常BUFFER_Length:", videoStream.info.videoBufferLength,"hasStreamComing:",streamInCome)	
						}	
						//ErrorToServerMgr.getLocal().add( { errorID:106, serverIp:fmsMgr.getFms().ip, serverPort:fmsMgr.getFms().port } );
					}catch (error:Error) {
						Log.out("Error:", "bufferLength", error.message);
					}
						
						
					fmsMgr.getFms().lag *= fmsMgr.status == FmsEvent.FMS_GETTING?1:2*ConstVal.LAG_RATIO;			
							
					retry();
				}	
				//syncAudioVideo();					
			}
			// buffer空30s不满就切换fms
			if (bufferKey)
			{				
				if (++bufferEmptyTimer >= 30)
				{
					//ErrorToServerMgr.getLocal().add( { errorID:107, serverIp:fmsMgr.getFms().ip, serverPort:fmsMgr.getFms().port } );
					Log.out(micIndex, "麦：长时间buffer为空，切换fms", "无流时间：", bufferEmptyTimer);
					fmsMgr.getFms().lag *= fmsMgr.status == FmsEvent.FMS_GETTING?1:ConstVal.LAG_RATIO;	
					retry();
				}
			}			
			
			
			//if (videoStream) trace(micIndex, "麦 videoStream:", videoStream.currentFPS);
			
		}	
		
		private function syncAudioVideo():void
		{
			if (Math.abs(videoStream.time - audioStream.time) > 1.5)
			{
				var pauseStream:NetStream;
				
				if (videoStream.time > audioStream.time)
				{
					pauseStream = videoStream;
				}else {
					pauseStream = audioStream;
				}
				
				pauseStream.togglePause();
				
				var pauseTimeHandler:Function = function()
				{
					//Log.out("音视频同步完成")
					pauseStream.togglePause();
				}
				
				setTimeout(pauseTimeHandler, uint(Math.abs(videoStream.time - audioStream.time) * 1000));
			}
		}
		
		private function volumeHandler(e:RtmpEvent):void 
		{
			volume = e.data as SoundTransform;
			if (audioStream)
			{
				audioStream.soundTransform = volume;
			}
		}
		
		/**
		 * 初始化或者上麦以后连接fms
		 * 
		 * */
		public function open():void
		{
			//忽略初始化时重复上麦
			if (status != RtmpEvent.CLOSE)
			{
				//已经连接不再重连
				return;
			}	
			unPublishedTag = false;
			streamInCome = false;
			status = RtmpEvent.OPEN;
			
			netConn = new NetConnection();
			netConn.client = this;
			
			configConnEvent(netConn);
			
			netConn.connect(fmsServerStr, getRoomID(), micIndex);
			
			/**开始转圈loading*/
			execute(new RtmpEvent(RtmpEvent.OPEN, status));
			
			if (!netWatcher.running)
			{
				netWatcher.reset();
				netWatcher.start();
			}						
		}
		
		
		/**
		 * 用户下麦关闭通道和流，重置状态
		 * */
		public function close():void
		{
			try {
				gc();
			  
				execute(new RtmpEvent(RtmpEvent.CLOSE, _user));
				
				_user = null;	
				
				netWatcher.stop();
				netWatcher.reset();
				bufferKey = false;
				bufferEmptyTimer = 0;
				
				status = RtmpEvent.CLOSE;
			}catch (e:Error) {
				Log.out("CLOSE:", e.message);
			}
			
		}	
		
		/**
		 * 添加NetConnection事件
		 * */
		private function configConnEvent(conn:NetConnection):void
		{
			if (!conn.hasEventListener(NetStatusEvent.NET_STATUS))
			{
				conn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler,false,0,true);
				conn.addEventListener(IOErrorEvent.IO_ERROR, errorHandler,false,0,true);
				conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler,false,0,true);
				conn.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler,false,0,true);	
			}			
		}
		
		/**
		 * 清理NetConnection事件
		 * */
		private function clearConnEvent(conn:NetConnection):void
		{
			if (conn.hasEventListener(NetStatusEvent.NET_STATUS)) 
			{
				conn.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				conn.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				conn.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				conn.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);	
			}			
		}
		
		/**
		 * 通道和流状态变化处理
		 * */
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			//trace(e.info.code);
			switch(e.info.code)
			{
				case "NetConnection.Connect.Success":
						onConnect();
					break;	
				case "NetConnection.Connect.IdleTimeout":
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.AppShutdown":
				case "NetConnection.Connect.InvalidApp":						
						onDisconnect(e.info!=null?e.info.code:"未知错误");
					break;						
				case "NetStream.Connect.Success": // e.info.stream;
					break;						
				case "NetStream.Connect.Rejected": // e.info.stream
				case "NetStream.Connect.Failed": // e.info.stream
						retry();							
					break;
				case "NetStream.Play.UnpublishNotify":
						unPublishedTag = true;
					break;
				case "NetStream.Play.Stop":	
					break;
				case "NetStream.Buffer.Empty":
						if (unPublishedTag) {
							unPublished();
						}else {
							bufferKey = true;
						}											
					break;
				case "NetStream.Buffer.Full":						
						bufferEmptyTimer = 0;
						bufferKey = false;
					break;
				case "NetStream.Unpause.Notify":
				case "NetStream.Pause.Notify":
				case "NetStream.Buffer.Flush":				
				case "NetStream.Seek.Notify":
					break;
				case "NetStream.Play.Start":
					//Log.out(micIndex, "麦开始播放");
					unPublishedTag = false;
					if (!netWatcher.running)
					{
						netWatcher.start();
					}
					break;
				default:
						Log.out(micIndex,"麦：rtmp 没有处理消息：", e.info.code);
					break;					
			}
		}
		
		/**
		 * 麦上用户关闭视频时候清除最后一帧，并停止流监测
		 * */
		private function unPublished():void 
		{		
			netWatcher.stop();
			execute(new RtmpEvent(RtmpEvent.RTMP_UNPUBLISHED));
		}
		
		/**
		 * 网络状态不好重新连接fms
		 * */
		private function retry():void 
		{
			bufferEmptyTimer = 0;
			bufferKey = false;
			netWatcher.stop();
			netWatcher.reset();
			
			gc();				
			try {
				fmsMgr.resortFMS();//取消切换fms 			
				if (fmsMgr.getFms().lag == uint.MAX_VALUE) {	
					fmsMgr.getFms().resetLAG();
					getMoreFMS()//取消切换fms 
					return;
				}
				
				Log.out(micIndex, "麦", "重连FMS", fmsMgr.getFms().ip, fmsMgr.getFms().port, "当前fms的质量：", fmsMgr.getFms().lag);
				
				status = RtmpEvent.CLOSE;					
				open();
			}catch (e:Error) {
				Log.out("retry:", e.message);
			}			
		}
		
		/**fms列表空了以后，请求新列表*/
		public function getMoreFMS():void {	
			
			if (fmsMgr.status != FmsEvent.FMS_GETTING) {
				Log.out(micIndex, "麦", "请求Fms服务器");						
				fmsMgr.dispatchEvent(new FmsEvent(FmsEvent.FMS_GETTING));	
			}
			if (timer.hasEventListener(TimerEvent.TIMER)) {
				timer.removeEventListener(TimerEvent.TIMER,checkfmshandler);
			}
			
			timer.addEventListener(TimerEvent.TIMER, checkfmshandler, false, 0, true);
			
			if (!timer.running) {
				timer.start();
			}
			
		}
		
		/**请求反馈检测*/
		protected function checkfmshandler(event:TimerEvent):void
		{			
			if(fmsMgr.status==FmsEvent.FMS_RECEIVE){
				timer.removeEventListener(TimerEvent.TIMER, checkfmshandler);
				timer.reset();
				Log.out(micIndex,"麦","请求FMs成功，重新连接")
				Log.out(micIndex,"麦",fmsMgr.toString())
				retry();	
				return;
			}
			//25秒fms没下来250*100=25000
			if (timer.currentCount > 100) {
				timer.reset();
				timer.removeEventListener(TimerEvent.TIMER, checkfmshandler);
				Log.out(micIndex, "麦", "向CAS请求FMS地址超过25秒,重置Lag");	
				//ErrorToServerMgr.getLocal().add( { errorID:103, serverIp:RoomModel.getRoomModel().roomProxyIp, serverPort:RoomModel.getRoomModel().roomProxyPort } );
				fmsMgr.resetAllLag();
				fmsMgr.status = FmsEvent.FMS_RECEIVE;
				retry();
			}
		}
		
		/**
		 * 通道建立成功，建立播放流信息
		 * */
		private function onConnect():void 
		{
			//图像
			videoStream = new NetStream(netConn);
			videoStream.useHardwareDecoder = false;
			videoStream.receiveAudio(false);
			videoStream.bufferTime = 0.5;		
			setFps(_fps);
			videoStream.client = this;
			configStreamEvent(videoStream);	
			videoStream.play(videoStr);
			
			//声音
			audioStream = new NetStream(netConn);
			audioStream.useHardwareDecoder = false;
			audioStream.receiveVideo(false);
			audioStream.bufferTime = 0.5;
			audioStream.client = this;			
			audioStream.play(audioStr);
			
			//if(micIndex==0)trace(JSON.stringify(audioStream));
			
			audioStream.soundTransform = volume;
						
			//ui开始播放视频
			execute(new RtmpEvent(RtmpEvent.RTMP_STREAM_PLAY, videoStream));	
			//快速出图像
			var changeBuffer:Function = function() {
				if (videoStream) {
					videoStream.bufferTime = videoStream.bufferTimeMax = 2;
					audioStream.bufferTime = audioStream.bufferTimeMax = 2;
				}				
			}			
			setTimeout(changeBuffer, 2000);
		}		
				
		
		/**
		 * 配置流监控事件
		 * */
		private function configStreamEvent(ns:NetStream):void
		{
			if (!ns.hasEventListener(NetStatusEvent.NET_STATUS))
			{
				ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler, false, 0, true);
				ns.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
				ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
				//ns.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaDataHandler, false, 0, true);	
			}			
		}
		
		/**
		 * 流中包含数据时候
		 * */
		/*private function mediaDataHandler(e:NetDataEvent):void 
		{
			//Log.out(micIndex,"时间戳：",e);
		}*/
		
		/**
		 * 回收流监控事件
		 * */
		private function clearStreamEvent(ns:NetStream):void
		{
			if (ns.hasEventListener(NetStatusEvent.NET_STATUS)) 
			{
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				ns.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				ns.removeEventListener(NetStatusEvent.NET_STATUS, errorHandler);
				//ns.removeEventListener(NetDataEvent.MEDIA_TYPE_DATA, mediaDataHandler);
			}			
		}
		
		/**
		 * 通道连接失败，切换fms重新连接
		 * */
		private function onDisconnect(des:String=""):void 
		{
			//ErrorToServerMgr.getLocal().add( { errorID:105, serverIp:fmsMgr.getFms().ip, serverPort:fmsMgr.getFms().port } );
			Log.out(micIndex, "麦", "NetConnection 连接失败：", des);
			//切换ip重试
			fmsMgr.getFms().lag = uint.MAX_VALUE;			
			retry();
		}
		
		/**处理异常事件*/
		private function errorHandler(e:Event):void
		{
			Log.out("Error:", e.toString());			
		}
		
		/**
		 * 相互绑定流的ui和rtmpStream
		 * @param value:GuaVideo 视频ui
		 * */
		public function set videoSkin(value:GuaVideo):void
		{			
			video = value;
			video.rtmp = this;
			Log.out(micIndex, "麦视频帧率:", ConstVal.frameVec[micIndex]);
			setFps(ConstVal.frameVec[micIndex]);
			clearEventMap();		
		}
		
		/**
		 * 清理ui绑定之前缓存的事件（用户下麦可以砍掉没处理的数据）
		 * */
		private function clearEventMap():void 
		{
			if (eventMap.length > 0) {
				var e:RtmpEvent = eventMap.splice(0, 1)[0];
				execute(e);
				clearEventMap();
			}
		}
		
		/**
		 * 在绑定ui以后直接派发事件，没绑定之前先缓冲时间，等待ui绑定。
		 * @param e:RtmpEvent 派发事件，可以带一个data:*属性。例如:new RtmpEvent(RtmpEvent.OPEN,data));
		 * */
		public function execute(e:RtmpEvent):void
		{			
			if (video != null) {				
				dispatchEvent(e);				
				return;
			}
			eventMap.push(e);
		}
		
		/**
		 * 垃圾回收，清理内存
		 * */
		private function gc():void 
		{
			try {
				
				unPublishedTag = false;
				
				if (videoStream)
				{
					clearStreamEvent(videoStream);	
					//clearStreamEvent(audioStream);
					videoStream.close();
					audioStream.close();
					
					videoStream.dispose();
					audioStream.dispose();		
					videoStream = null;
					audioStream = null;	
				}							
				
				if (netConn) {
					clearConnEvent(netConn);
					if (netConn.connected)
					{
						netConn.close();
					}
					netConn = null;
				}
					
				if (timer.running)
				{
					timer.stop();
					timer.reset();
					timer.removeEventListener(TimerEvent.TIMER, checkfmshandler);
				}
			}catch (e:Error){
				Log.out("Gc:", e.message);
			}
				
		}
		
		/**
		 * 返回FmsManager中质量最好的一个fms服务器组合而成的rtmp地址。 
		 * */
		private function get fmsServerStr():String
		{			
			return "rtmp://" + fmsMgr.getFms().ip + ":" + fmsMgr.getFms().port + "/chat";
		}
		
		/**
		 * 播放视频流的名称
		 * */
		private function get videoStr():String
		{
			return "stream_room_" + getRoomID() + "_" + String(micIndex + 1)+"_v";
		}
		
		/**房间id*/
		private function getRoomID():String
		{
			return String(RoomModel.getRoomModel().myRoomInfo.m_szRoomId);
		}
		
		/**
		 * 播放音频流的名称
		 * */
		private function get audioStr():String
		{
			return "stream_room_" + getRoomID() + "_" + String(micIndex + 1)+"_a"
		}
		
		/**
		 * 用户上麦以后，申请鲜花总数回调
		 * @param value:Object 包含明星信息的对象
		 * */
		public function flowerBackCall(value:Object):void {
			//trace(JSON.stringify(value));
			if (_user) execute(new RtmpEvent(RtmpEvent.FLOWER_DATA, value));
		}
		
		/**等待bspAPI完成以后请求用户鲜花数*/
		private function getUserFlower():void
		{
			if (_user)
			{
				if (RoomModel.getRoomModel().bspAPI)
				{
					RoomModel.getRoomModel().bspAPI._6001(_user.uid, 7, flowerBackCall);					
				}else {
					Log.out("bspAPI未完成,稍候请求")
					setTimeout(getUserFlower, 1000);
				}				
			}			
		}
		
		/**
		 * 设置麦上用户
		 * @param value:UserInfo 上麦用户模型
		 * */
		public function set user(value:UserInfo):void 
		{
			//处理没有收到下麦收到不同人上麦的情况：例如可能的夺麦。
			if (_user!=null&&_user.uid != value.uid)
			{
				close();
				open();
			}
			_user = value;		
			getUserFlower()
			execute(new RtmpEvent(RtmpEvent.USER_INIT, value));
		}
		
		/**获取麦号*/
		public function get micIndex():uint 
		{
			return _micIndex;
		}
		
		/**流播放帧率，默认30fps*/	
		private function setFps(value:uint=0):void 
		{
			_fps = value;
			if (videoStream)
			{
				videoStream.receiveVideoFPS(_fps);
			}
		}
		
		
		/**通道连接成功回调*/
		public function onBWDone(value:Object=null):void {
			Log.out(micIndex,"麦","通道连接成功",JSON.stringify(value));
		}
		/**流连接成功回调*/
		public function onMetaData(value:Object=null):void {
			Log.out(micIndex, "麦", "流连接成功", JSON.stringify(value));			
		}
	}	
	
}