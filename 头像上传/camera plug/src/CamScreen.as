package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;
	
	[Event(name="complete", type="flash.events.Event")]
	
	public class CamScreen extends Sprite
	{
		private var countDown:Countdown;
		private var video:Video;
		
		private var _bitmapdata:BitmapData;

		private var cam:Camera;
		
		private var W:Number=250;
		private var H:Number=250;
		
		private var timer:Timer;
		
		public function CamScreen()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		public function get bitmapdata():BitmapData
		{
			return _bitmapdata;
		}

		public function set bitmapdata(value:BitmapData):void
		{
			_bitmapdata = value;
		}

		protected function onRemove(event:Event):void
		{			
			countDown.removeEventListener(Event.COMPLETE,onRemove);
			if(bitmapdata&&video)
			{				
				bitmapdata.draw(video,null,null,null,null,true);
			}
			this.dispatchEvent(new Event(Event.COMPLETE));			
		}
		
		public function dispose():void
		{
			if(bitmapdata)
			{				
				bitmapdata.dispose();	
			}
			if(video&&this.contains(video))
			{
				video.attachCamera(null);
				video.clear();
				this.removeChild(video);
				video=null;
			}
			
			cam=null;
			if(timer)
			{
				timer.stop();
				timer=null;				
			}
			
			if(countDown)
			{
				countDown.dispose();
			}
		}
		
		protected function onAdded(event:Event):void
		{				
			bitmapdata=new BitmapData(W,H,true,0x00ffffff);
			video=new Video(W,H);
			video.smoothing=true;
			cam=Camera.getCamera();
			
			if(cam)
			{
				cam.setMode(video.width,video.height,15);
				cam.setQuality(0,60);
				cam.setMotionLevel(cam.activityLevel,100);
				cam.addEventListener(StatusEvent.STATUS,statusHandler,false,0,true);
				cam.addEventListener(ActivityEvent.ACTIVITY,activHandler,false,0,true);
				video.attachCamera(cam);
				this.addChild(video);	
				timer=new Timer(100);
				timer.addEventListener(flash.events.TimerEvent.TIMER,function():void
				{
					if(cam.currentFPS>0)
					{
						timer.stop();					
					}else if(timer.currentCount>10){
						trace("CAMERA--->摄像头被占用");
						timer.stop();
					}
				},false,0,true);
				timer.start();
			}else{
				trace("CAMERA--->没有找到摄像头");
			}
		}
		
		protected function activHandler(event:ActivityEvent):void
		{
			if(!this.contains(countDown)){				
				trace(cam.quality,cam.currentFPS,cam.bandwidth);				
				this.addChild(countDown);
			}
		}
		
		protected function statusHandler(event:StatusEvent):void
		{
			if(event.code=="Camera.unMuted")
			{
				
			}else{
				trace("CAMERA--->您拒绝了获取摄像头数据");
			}
		}
		
		static public function get isSupported():Boolean
		{
			return Camera.isSupported;
		}
		
		public function setSize(w:Number, h:Number):void
		{
			if(!countDown)
			{
				countDown=new Countdown(w,h);
				
				countDown.addEventListener(Event.COMPLETE,onRemove);
			}
			
			W=w;
			H=h;			
		}
	}
}