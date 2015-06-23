package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * 2013-9-10 9:58
	 * @author idzeir mailto:qiyanlong@wozine.com
	 */
	public class Monitor extends Sprite 
	{
		/**平滑帧*/
		private var smoothFps:Number;
		/**上个时间点*/
		private var prevTime:uint = 0;
		/**占用内存峰值*/
		private var maxMem:uint = 0;
		
		private var infoTxt:TextField = new TextField();
		
		public function Monitor() 
		{
			var tf:TextFormat = new TextFormat("_sans", 12,0xffffff);
			tf.letterSpacing = 1;
			tf.leftMargin = 2;
			tf.rightMargin = 2;
			tf.leading = 2;
			
			infoTxt.autoSize = "left";
			infoTxt.defaultTextFormat = tf;
			infoTxt.filters=[new GlowFilter(0x000000,1,1.2,1.2,20)]
			//infoTxt.border = true;
			//infoTxt.borderColor = 0x000000;
			this.addChild(infoTxt);
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
		private function onAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			smoothFps = stage.stage.frameRate;
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void 
		{
			var rate:Number = 1 / (1024 * 1024);
			var delta:uint = getTimer() - prevTime;
			if (delta <= 0) return;
			
			var fps:Number = 1000 / delta;
			var curMem:Number = System.totalMemory;
			maxMem = Math.max(maxMem, curMem);
			smoothFps = smoothFps * 0.99 + fps * 0.01;//控制平滑波动
			
			infoTxt.text = "帧频:" + smoothFps.toFixed(2) + " 内存:" + Number(curMem * rate).toFixed(2) + " 峰值:" + Number(maxMem * rate).toFixed(2);
			
			prevTime = getTimer();
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			this.removeEventListener(Event.ENTER_FRAME, update);
		}
		
	}

}