package com.guagua.ui 
{	
	import flash.display.DisplayObject;	
	import flash.display.Sprite;
	import flash.events.Event;	
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class MicStatusDef extends Sprite 
	{
		private var statusCircleDef:DisplayObject;
		
		private var _isOpen:Boolean = false;
		
		public function MicStatusDef() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			statusCircleDef = this.getChildByName("statusCircle") as DisplayObject;
			statusCircleDef.visible = false;			
		}
		
		public function get open():Boolean 
		{
			return _isOpen;
		}
		
		public function set open(value:Boolean):void 
		{
			_isOpen = value;
			statusCircleDef.visible = open;
		}	
		
	}

}