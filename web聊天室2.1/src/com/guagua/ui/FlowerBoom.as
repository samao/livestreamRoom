package com.guagua.ui 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class FlowerBoom extends MovieClip 
	{
		
		public function FlowerBoom() 
		{			
			addFrameScript(this.totalFrames-1, frameendAS);
		}
		
		private function frameendAS():void 
		{		
			try {
				this.stop();
				this.parent.removeChild(this);	
			}catch (e:Error) {
				Log.out("Boom", e.message);
			}
					
		}
		
	}

}