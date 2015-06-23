package com.guagua.chat.model
{
	/**
	 *@author weiwen
	 * 麦上用户
	 * 对应C++ STRU_MIC_STATE_INFO
	 */
	public class MicUserInfo
	{
		//麦序号
		public var micIndex:Number;
		//麦的状态  (bit-0:On/off; bit-1:Mode; bit-2:Limit; bit-3:Video)
		public var micState:Number;
		//当前管理员ID
		public var managerID:Number;
		//麦时(秒)
		public var micTime:Number;
		//当前发言人ID
		public var speakUserID:Number=0;
		//语音流ID
		public var stopSpeakTime:Number;
		//视频流id
		public var startTime:Number;
		//用户名
		public var micName:String="";
		
		public function MicUserInfo(index:int)
		{
			micIndex=index;
		}
		
		public function getJsObj():Object{
			var obj:Object = new Object();
			obj.micIndex = micIndex;
			obj.micState = micState;
			obj.managerID = managerID;
			obj.micTime = micTime;
			obj.speakUserID = speakUserID;
			obj.stopSpeakTime = stopSpeakTime;
			obj.startTime  = micName;
			obj.micName=micName;
			return obj;
		}
		
	}
}