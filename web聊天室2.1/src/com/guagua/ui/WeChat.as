package com.guagua.ui 
{
	import com.guagua.chat.model.RoomModel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class WeChat extends Sprite 
	{
		public var mic:uint = 0;
		
		public function WeChat() 
		{
			buttonMode = true;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			RoomModel.getRoomModel().iPlayer.chatWithStar(mic);
		}
		
	}

}