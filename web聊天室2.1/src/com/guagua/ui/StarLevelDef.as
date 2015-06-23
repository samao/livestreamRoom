package com.guagua.ui
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	/**
	 *@Date:2012-12-6 下午04:18:47	
	 */
	
	public class StarLevelDef extends MovieClip
	{
		public function StarLevelDef()
		{
			visible=false;
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			stop();
		}
		
		/**显示等级帧*/
		public function set level(value:uint):void{			
			this.visible=(value!=0);
			if(value!=0){
				this.gotoAndStop(value);
			}
		}
	}
}