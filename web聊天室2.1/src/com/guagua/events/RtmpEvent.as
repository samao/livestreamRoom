package com.guagua.events
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class RtmpEvent extends Event 
	{
		/**用户上麦开始连接fms派发*/
		static public const OPEN:String = "open";
		/**用户下麦派发*/
		static public const CLOSE:String = "close";
		/**获取用户信息派发*/
		static public const USER_INIT:String = "userInit";
		/**回去到鲜花派发*/
		static public const FLOWER_DATA:String = "flowerData";
		/**音频状态改变*/
		static public const RTMP_AUDIO_CHANGE:String = "rtmpAudioChange";
		/**流准备好以后派发*/
		static public const RTMP_STREAM_PLAY:String = "rtmpStreamPlay";
		/**音量变化派发*/
		static public const RTMP_VOLUME:String = "rtmpVolume";
		/**麦上用户关闭视频*/
		static public const RTMP_UNPUBLISHED:String = "unPublished";
				
		/**事件所带数据*/
		public var data:*;
		
		public function RtmpEvent(type:String,_data:*=null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			data = _data;
			super(type, bubbles, cancelable);			
		} 
		
		public override function clone():Event 
		{ 
			return new RtmpEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("RtmpEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}