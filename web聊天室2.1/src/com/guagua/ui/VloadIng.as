package com.guagua.ui
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class VloadIng extends MovieClip
	{
		public function VloadIng()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		}
		
		private function onAddedStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
			this.visible = false;			
		}
	}
}