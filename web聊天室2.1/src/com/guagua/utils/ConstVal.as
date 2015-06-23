package com.guagua.utils 
{
	import com.guagua.chat.model.RoomModel;
	import flash.display.BitmapData;
	import flash.text.TextField;
	/**
	 * ...
	 * @author idzeir
	 */
	public class ConstVal 
	{
		/**送明星花事件标识*/
		static public const FLOWER:String = "flower";
		/**送明星礼物事件标识*/
		static public const GIFT:String = "gift";
		/**打开视频事件标识*/
		static public const OPEN_VIDEO:String = "openVideo";
		/**关闭视频事件标识*/
		static public const CLOSE_VIDEO:String = "closeVideo";
		/**打开音频事件标识*/
		static public const OPEN_AUDIO:String = "openAudio";
		/**关闭音频事件标识*/
		static public const CLOSE_AUDIO:String = "closeAudio";
		/**调节音量事件标识*/
		static public const SOUND_CHANGE:String = "soundChange";
		/**调试模式*/
		static public const DEBUG_MODE:Boolean = true;
		
		/**延时增长系数*/
		static public const LAG_RATIO:uint = 2;
		
		/**一次鲜花数量为0时一次送出全部鲜花*/
		static public var MAX_SEND_FLOWERS:Number = 1;
		/**鲜花最多存量上限*/
		static public var MAX_FLOWERS_LIMITED:Number = 1;
		/**当前鲜花数*/
		static private var CUR_FLOWERS:Number = 0;
		
		/**明星等级bitmapData*/
		static private var STAR_BITMAPDATA:BitmapData;
		
		static public var ICO_WIDTH:Number = 28;
		static public var ICO_HEIGHT:Number = 16;
		
		static public const STAR_ICO_URL:String = "statics/flash/ico.png";
		
		/**播放器公开版本类型，1为合作版，0为官方版*/
		static public var PLAYER_TYPE:Number = 1;
		
		static private const REBROADER_MIN_ID:uint = 9900000000;
		static private const REBROADER_MAX_ID:uint = 9999999999;		
		
		/**去掉黑边以后的视频高度*/
		//static public var videoHeight:Vector.<Number> = new Vector.<Number>();
		
		/**视频帧率*/
		static public var frameVec:Vector.<uint> = new Vector.<uint>();		
		
		/**CAS标识*/
		static public const SERVER_TYPE_CAS:String = "cas";
		
		/**BSP标识*/
		static public const SERVER_TYPE_BSP:String = "bsp";
		
		/**CQS标识*/
		static public const SERVER_TYPE_CQS:String = "cqs";
		
		/**ACS标识*/
		static public const SERVER_TYPE_ACS:String = "acs";
		
		static private var orgDate:Date;
		
		/**视频显示标识*/
		static public var videoEnabled:Boolean = false;
		
		public function ConstVal() {
			throw new Error("ConstVal是静态类，不允许实例化。*^_^*")
		}
		
		static public function isRebroader(uid:uint):Boolean {
			return (uid >= REBROADER_MIN_ID && uid <= REBROADER_MAX_ID);
		}
		
		static public function get FLOWERS():Number 
		{
			return CUR_FLOWERS;
		}
		
		static public function set FLOWERS(value:Number):void 
		{
			//CUR_FLOWERS = value > MAX_FLOWERS_LIMITED?MAX_FLOWERS_LIMITED:value;
			CUR_FLOWERS = value;
			RoomModel.getRoomModel().iPlayer.myFlowerCount = ConstVal.FLOWERS;
		}
		
		static public function get BITMAPDATA():BitmapData 
		{
			if (STAR_BITMAPDATA == null) {
				/**未找到外部ico资源*/
				//STAR_BITMAPDATA = new BitmapData(168, 160, true,0x00ffffff);
			}
			
			return STAR_BITMAPDATA;
		}
		
		static public function set BITMAPDATA(value:BitmapData):void 
		{
			//设置每个图标宽高；
			if (STAR_BITMAPDATA != null) {
				STAR_BITMAPDATA.dispose();
			}

			ICO_WIDTH = value.width / 6;
			ICO_HEIGHT = value.height / 10;
			
			STAR_BITMAPDATA = value;
		}
		
		static public function get date():Number 
		{
			if (orgDate == null) {
				orgDate = new Date();
			}
			var _date:Date = new Date();
			return Number(Number((_date.time-orgDate.time) * .001).toFixed(3));
		}
		
		
	}

}