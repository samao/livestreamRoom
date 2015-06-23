package com.guagua.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class UIEvent extends Event 
	{
		/**视频控制条派发事件*/
		static public const UI_CHANGED:String = "uiChanged";
		
		/**执行命令*/
		private var _cmd:String = "";
		
		public function UIEvent(type:String,_paramcmd:String="", bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_cmd = _paramcmd;
		} 
		
		public override function clone():Event 
		{ 
			return new UIEvent(type,cmd, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("UIEvent", "type","cmd", "bubbles", "cancelable", "eventPhase"); 
		}
		
		/**执行命令类型*/
		public function get cmd():String 
		{
			return _cmd;
		}
		
	}
	
}