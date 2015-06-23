package com.guagua.normal
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	/**
	 * 普通渲染模式
	 *@Date:2012-10-25 上午11:54:55	
	 */
	
	public class World extends Sprite
	{
		public function World()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			trace("This is normal world")
			
			this.addChild(new MainEntry());
		}
	}
}