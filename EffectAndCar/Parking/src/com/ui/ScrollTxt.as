package com.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.TextAlign;
	
	/**
	 * 滚动文本
	 *@Date:2012-11-5 下午06:07:24	
	 */
	
	public class ScrollTxt extends Sprite
	{
		/**可见区域*/
		private var viewPort:Rectangle;
		/**可见区域遮罩*/
		private var viewPortDef:Sprite;
		/**滚动速度*/
		private var speed:uint;
		/**滚动文本信息*/
		public var content:TextField=new TextField();
		/**刷新时间*/
		public var timer:Timer=new Timer(50);
		
		static private var _instance:ScrollTxt;
		
		/**
		 * 滚动文本
		 * @param rect:文本可见区域
		 * @param hSpeed：滚动速度
		 * */
		public function ScrollTxt(rect:Rectangle,hSpeed:uint=0)
		{
			super();
			
			speed=hSpeed;
			viewPort=rect;
			content.autoSize=TextFieldAutoSize.LEFT;
			content.textColor=0xffffff;
			var tf:TextFormat=new TextFormat();
			tf.align=TextFormatAlign.CENTER;
			tf.bold=true;
			tf.font="微软雅黑";			
			content.mouseEnabled=false;			
			drawViewPort();
			content.y=-10;
			this.addChild(content);
		}
		
		/**按照可见区域绘制遮罩形状*/
		private function drawViewPort():void
		{
			viewPortDef=new Sprite();
			viewPortDef.graphics.beginFill(0x343434,1);
			viewPortDef.graphics.drawRect(viewPort.left,viewPort.top,viewPort.width,viewPort.height);
			viewPortDef.graphics.endFill();
			this.addChild(viewPortDef);
			viewPortDef.y=-10;
			this.addChild(content);			
			this.mask=viewPortDef;
		}
		
		/**设置文本字串*/
		public function setText(arg:String=""):void{
			content.text=arg;			
		}
		
		/**优化性能清除滚动动画，定时器。保持同一时间只有一个滚动动画*/
		private function clearTimer():void{			
			if(_instance!=null&&_instance.timer.hasEventListener(TimerEvent.TIMER)){
				_instance.timer.removeEventListener(TimerEvent.TIMER,_instance.timerHandler);
			}
			_instance=this;
		}
		
		/**
		 * 文本滚动设置器
		 * @param ok:参数true表示开始滚动，false为停止滚动
		 * */
		public function startRoll(ok:Boolean):void{			
			if(ok){			
				//判断滚动与否，是否添加帧听；
				if(!timer.hasEventListener(TimerEvent.TIMER)&&viewPort.width<content.width){					
					clearTimer()
					timer.addEventListener(TimerEvent.TIMER,timerHandler);
					timer.start()
				}								
				return
			}	
			
			//停止滚动时候删除帧听事件
			if(timer.hasEventListener(TimerEvent.TIMER)){
				content.x=0;
				timer.removeEventListener(TimerEvent.TIMER,timerHandler);
				timer.stop()
				timer.reset();
			}
		}
		
		/**基于时间的动画*/
		public function timerHandler(event:TimerEvent):void
		{
			content.x-=viewPort.width<content.width?speed:0;
			if(content.x<-content.width){
				content.x=viewPort.width;
			}
		}
		
		/**基于帧的动画*/
		private function moveTxtHandler(event:Event):void
		{
			content.x-=viewPort.width<content.width?speed:0;
			if(content.x<-content.width){
				content.x=viewPort.width;
			}
		}
		
		/**优化性能回收事件*/
		public function destroy():void{
			//删除帧动画
			/*if(this.hasEventListener(Event.ENTER_FRAME)){
				this.removeEventListener(Event.ENTER_FRAME,moveTxtHandler);	
				
			}*/
			//删除时间动画帧听器
			if(timer.hasEventListener(TimerEvent.TIMER)){
				content.x=0;
				timer.removeEventListener(TimerEvent.TIMER,timerHandler);
				timer.stop()
				timer.reset();
			}
		}
	}
}