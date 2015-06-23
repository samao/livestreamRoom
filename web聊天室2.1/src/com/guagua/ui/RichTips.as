package com.guagua.ui
{
	import flash.utils.Timer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import com.guagua.utils.ConstVal;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class RichTips extends Sprite 
	{
		private var style:StyleSheet = new StyleSheet();
		
		private var tipTxt:TextField;
		
		private var timer:Timer = new Timer(1000, 1);
		
		public function RichTips() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onStage);
			visible = false;
		}
		
		private function onStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStage);
			
			style.parseCSS("a:link { text-decoration:none; }");
			style.parseCSS("a:hover { text-decoration:underline; }");			
			
			tipTxt = this.getChildByName("Txt") as TextField;
			
			tipTxt.styleSheet = style;
			
			tipTxt.addEventListener(TextEvent.LINK, linkHandler);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);		
			
			
			reflush();
		}
		
		private function overHandler(e:MouseEvent):void 
		{			
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:	
					timer.reset();
					timer.stop();
					break;
				case MouseEvent.MOUSE_OUT:
					timer.reset();
					timer.start();					
					break;
			}
		}
		
		public function show(ok:Boolean = true,tag:Boolean=false):void {
			
			if (!ok) {
				//trace("鼠标移除去了")
				timer.reset();
				timer.start();	
				
				if (!this.hasEventListener(MouseEvent.MOUSE_OVER)) {
					this.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
					this.addEventListener(MouseEvent.MOUSE_OUT, overHandler);
				}
				
				return;
			}			
			timer.stop();
			this.visible = true;
		}
		
		private function clearEvents():void {
			if (this.hasEventListener(MouseEvent.MOUSE_OVER)) {
				this.removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
				this.removeEventListener(MouseEvent.MOUSE_OUT, overHandler);
			}
		}
		
		
		private function timerHandler(e:TimerEvent):void 
		{			
			this.visible = false;	
			clearEvents();
		}
		
		private function linkHandler(e:TextEvent):void 
		{
			Log.out("鲜花设置面板");
			if (ExternalInterface.available) {
				ExternalInterface.call("flowerOption");
			}
		}
		
		public function reflush():void {
			tipTxt.htmlText="您已累积了<font color='#ff0000'>" +ConstVal.FLOWERS + "</font>朵鲜花、点击送给主播<font color='#ff0000'>" + (ConstVal.MAX_SEND_FLOWERS==0?ConstVal.FLOWERS:ConstVal.MAX_SEND_FLOWERS) + "</font>朵鲜花，设置送花请<font color='#ff0000'><a href='event:myText'>查看说明</a></font>"
		}
		
		
		
	}

}