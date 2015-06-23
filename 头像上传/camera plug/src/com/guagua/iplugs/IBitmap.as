package com.guagua.iplugs
{
	import flash.display.BitmapData;

	public interface IBitmap
	{
		/**
		 * 获取摄像头拍照图片数据
		 * */
		function get bitmapdata():BitmapData;
		
		/**
		 * 摄像头拍照完毕以后回调
		 * @param fun:Function 回调的主程序函数，此函数包含以后bitmapData的参数
		 * */
		function shotComplete(fun:Function):void;
		
		/**
		 * 设置摄像头拍照的显示大小
		 * @param w:Number 显示宽
		 * @param h:Number 显示高
		 * */
		function setWH(w:Number=250,h:Number=250):void;
	}
}