package com.guagua.interfaces
{
	import com.guagua.chat.model.UserInfo;
	import flash.display.DisplayObject;
	
	/**
	 *@Date:2012-11-20 上午10:09:58	
	 */
	
	public interface IPlayer
	{
		/**初始化舞台*/
		function initStage():void
		
		/**用户上麦*/
		function addMicUser(user:UserInfo, mic:uint):String
		
		/**用户下麦*/
		function delMicUser(user:UserInfo, mic:uint):String
		
		/**关闭所有麦*/
		function delAllMicUser():String
		
		/**视频方案*/
		function videoStyle(value:uint):void
		
		/**献明星花*/
		function addFlower(uid:Number, flowerCount:uint):void
		
		/**房间状态改变*/
		function roomStateChange(value:Number):void;
		
		/**设置用户自己鲜花数*/
		function set myFlowerCount(value:uint):void;
		
		/**tip提示*/
		function tipsTool(value:String, host:DisplayObject = null, subHost:DisplayObject = null):void;
		
		/**显示全部打开按钮*/
		function showAllOpen(mic:uint, value:Boolean = false):void;
		
		/**和明星聊天*/
		function chatWithStar(mic:uint):void;
		
		/**显示鲜花tips*/
		function showFlowerTips(bool:Boolean,mic:uint):void;
	}
}