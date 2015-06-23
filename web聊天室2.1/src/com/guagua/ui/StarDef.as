package com.guagua.ui 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class StarDef extends MovieClip 
	{
		static public var count:uint = 0;
		
		public function StarDef() 
		{
			addFrameScript(this.totalFrames-1, frameendAS);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);			
		}
		
		private function onAdded(e:Event):void 
		{
			count++;
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			//trace("onAdded ",parent)
		}
		
		private function frameendAS():void 
		{
			try {
				count--;
				this.stop();
				this.parent.removeChild(this);				
			}catch (e:Error) {
				Log.out("Boom", e.message);
			}
		}
		
	}

}