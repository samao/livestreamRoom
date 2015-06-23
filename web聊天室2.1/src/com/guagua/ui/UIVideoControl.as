package com.guagua.ui 
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	import com.guagua.events.UIEvent;
	import com.guagua.utils.ConstVal;
	/**
	 * ...
	 * @author Wen
	 */
	public class UIVideoControl extends Sprite
	{
		public var btn_showVideo:SimpleButton;
		public var btn_closeVideo:SimpleButton;
		public var btn_showAudio:SimpleButton;
		public var btn_closeAudio:SimpleButton;
		
		public var xhuaBtn:SimpleButton;//鲜花
		public var goodsBtn:SimpleButton;//礼物

		private var _timeId:int;
		private var _cmd:String;

		public var soundMc:UISoundBtn;
		private var videoAlpha:Number = 1;
		
		public var allClosed:Boolean = false;
		
		public function UIVideoControl() 
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onaddedStage);	
			this.addEventListener("openAll", openAllHandler);
		}
		
		private function openAllHandler(e:Event):void 
		{
			btn_showVideo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			btn_showAudio.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function onaddedStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onaddedStage);
			
			//this.visible = false;
			btn_showVideo.addEventListener(MouseEvent.CLICK, Click);
			btn_closeVideo.addEventListener(MouseEvent.CLICK, Click);
			btn_showAudio.addEventListener(MouseEvent.CLICK, Click);
			btn_closeAudio.addEventListener(MouseEvent.CLICK, Click);
			//xhuaBtn.addEventListener(MouseEvent.CLICK, Click);
			//goodsBtn.addEventListener(MouseEvent.CLICK, Click);
			soundMc.addEventListener("changeSound", ChangeSound);
			InitSet();
		}
		
		public function InitSet(s:Number = 1, v:Number = 1):void {
			if (s >0 ){
				btn_showAudio.visible = false;
				btn_closeAudio.visible = true;
			} else {
				btn_showAudio.visible = true;
				btn_closeAudio.visible = false;
			}
			if (v >0){
				btn_showVideo.visible = false;
				btn_closeVideo.visible = true;
			} else {
				btn_closeVideo.visible = false;
				btn_showVideo.visible = true;
			}
			videoAlpha = v;
			soundMc.InitSound(s);
		}

		private function Click(e:MouseEvent):void {
			//trace(e.target.name);
			_cmd = e.target.name;
			switch (e.target.name){
				case "btn_showVideo":
					btn_showVideo.visible = false;
					btn_closeVideo.visible = true;
					videoAlpha = 1;		
					_cmd = ConstVal.OPEN_VIDEO;
					break;
				case "btn_closeVideo":
					videoAlpha = 0;
					btn_showVideo.visible = true;
					btn_closeVideo.visible = false;
					_cmd = ConstVal.CLOSE_VIDEO;
					break;
				case "btn_showAudio":
					btn_showAudio.visible = false;
					btn_closeAudio.visible = true;
					soundMc.Close(false);		
					_cmd = ConstVal.OPEN_AUDIO;
					break;
				case "btn_closeAudio":
					btn_showAudio.visible = true;
					btn_closeAudio.visible = false;
					soundMc.Close(true);
					_cmd = ConstVal.CLOSE_AUDIO;
					break;
				case "xhuaBtn":
					_cmd = ConstVal.FLOWER;
					break;
				case "goodsBtn":
					_cmd = ConstVal.GIFT;
					break;
			}			
			allClosed = (btn_showAudio.visible&&btn_showVideo.visible);
			this.dispatchEvent(new UIEvent(UIEvent.UI_CHANGED, _cmd));
			
			
		}

		/**获取执行的命令*/
		public function get ControlCmd():String {
			return _cmd;
		}

		private function ChangeSound(e:Event):void {			
			if (soundMc.volume == 0){
				btn_showAudio.visible = true;
				btn_closeAudio.visible = false;
			} else {
				btn_showAudio.visible = false;
				btn_closeAudio.visible = true;
			}	
			allClosed = (btn_showAudio.visible&&btn_showVideo.visible);
			this._cmd = ConstVal.SOUND_CHANGE;
			this.dispatchEvent(new UIEvent(UIEvent.UI_CHANGED,_cmd));
		}
		
		public function get volume():Number {			
			return soundMc.volume;
		}
		
		public function get videoalpha():Number {
			return videoAlpha;
		}
		
	}

}