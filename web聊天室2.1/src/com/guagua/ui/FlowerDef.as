package com.guagua.ui
{	
	
	import com.guagua.chat.model.RoomModel;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	//import com.guagua.filters.FiltersOperation;
	import com.guagua.utils.ConstVal;	
	
	public class FlowerDef extends Sprite {
		
		public var efDef:Sprite;	
		private var _status:String = FlowerStatus.FLOWER_EMPTY;
		private var tips:String = "12";
		
		private var _flowerCount:uint = 0;
		
		public var micIndex:uint = 0;
		
		private var fTxt:TextField;

		public function FlowerDef() {
			this.buttonMode=true;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);			
		}
		
		private function onAdded(e:Event):void{
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);					
			efDef=this.getChildByName("ef") as Sprite;
			efDef.visible = false;	
			
			var fbk:SimpleButton = this.getChildByName("bk") as SimpleButton;
			fbk.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			fbk.addEventListener(MouseEvent.MOUSE_OUT, overHandler);
			
			status = FlowerStatus.FLOWER_EMPTY;
			
			fTxt = this.getChildByName("Txt") as TextField;	
			
			var tf:TextFormat = new TextFormat();
			tf.bold = true;
			fTxt.defaultTextFormat = tf;
			
			flowerCount = 0;
		}
		
		private function overHandler(e:MouseEvent):void 
		{
			var videoStyleIndex:uint = RoomModel.getRoomModel().videoStyleIndex;
			switch(e.type) {
				case MouseEvent.MOUSE_OVER:
					if (videoStyleIndex < 2) {
						RoomModel.getRoomModel().iPlayer.tipsTool(tips,this, this["bk"]);
					}else {
						RoomModel.getRoomModel().iPlayer.showFlowerTips(true,micIndex);
					}
					
					efDef.visible = (status != FlowerStatus.FLOWER_EMPTY && ConstVal.FLOWERS >= ConstVal.MAX_SEND_FLOWERS);
					break;
				case MouseEvent.MOUSE_OUT:
					if (videoStyleIndex < 2) {
						RoomModel.getRoomModel().iPlayer.tipsTool("",this, this["bk"]);
					}else {
						RoomModel.getRoomModel().iPlayer.showFlowerTips(false,micIndex);
					}
					
					efDef.visible = false;
					break;
			}
			e.stopPropagation();
		}
		
		public function get status():String 
		{
			return _status;
		}
		
		public function set status(value:String):void 
		{
			_status = value;
			if (status == FlowerStatus.FLOWER_EMPTY) {
				tips = "您的鲜花当前为0朵\n请继续积累！";
				//FiltersOperation.glayFilter(this);
			}else if (status == FlowerStatus.FLOWER_FULL) {
				tips = "鲜花已满";
				//FiltersOperation.glowFilter(this);
			}else {
				tips = "现存" + ConstVal.FLOWERS + "朵鲜花";
				//FiltersOperation.clearFilter(this);
			}
		}
		
		public function get flowerCount():uint 
		{
			return _flowerCount;
		}
		
		public function set flowerCount(value:uint):void 
		{			
			_flowerCount = RoomModel.getRoomModel().myUserInfo.isGuest?0:value;			
			fTxt.text = "" + _flowerCount;	
		}
		
		
		
	}
	
}
