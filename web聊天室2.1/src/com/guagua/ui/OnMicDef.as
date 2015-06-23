package com.guagua.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class OnMicDef extends Sprite 
	{
		
		public function OnMicDef() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void 
		{
			//this.visible = false;
			buttonMode = true;
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);			
		}
		
		override public function set visible(value:Boolean):void 
		{
			//trace("override visible:", value);
			if (value)
			{
				this.addEventListener(MouseEvent.CLICK, clickHandler);
			}else {
				if (hasEventListener(MouseEvent.CLICK)) this.removeEventListener(MouseEvent.CLICK, clickHandler);
			}
			super.visible = value;
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			Log.out("请下载");
			if (ExternalInterface.available) {
				try {
					ExternalInterface.call("flashLoadAction");
				}catch (e1:Error) {
					trace("未定义js函数","onData")
				}
				
			}
		}
		
	}

}