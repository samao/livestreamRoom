package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class Countdown extends Sprite
	{
		private var txt:TextField=new TextField();
		
		private var count:uint=5;

		private var W:Number;

		private var H:Number;

		private var inter:Number;
		
		public function Countdown(w:Number,h:Number)
		{
			super();
			W=w;
			H=h;
			
			graphics.lineStyle(5,0xffffff);
			graphics.drawCircle(0,0,50);
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			count=5;
			txt.width=100;
			txt.autoSize="center";
			var tf:TextFormat=new TextFormat(null,50,0xffffff,true);
			txt.defaultTextFormat=tf;
			txt.text=""+count;
			txt.x=-.5*txt.width;
			txt.y=-.5*txt.height;
			this.addChild(txt);
			this.alginToStage();
			
			inter=setTimeout(play,1000);
		}
		
		private function play():void
		{
			txt.text=--count+"";
			if(count==0)
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
				this.parent.removeChild(this);
				return
			}
			inter=setTimeout(play,1000);
		}
		
		public function alginToStage():void
		{
			this.x=W>>1;
			this.y=H>>1;
		}
		
		public function dispose():void
		{
			//trace(this,count)
			flash.utils.clearTimeout(inter);
			count=5;
		}
	}
}