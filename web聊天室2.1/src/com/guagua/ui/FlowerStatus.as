package com.guagua.ui
{
	/**
	 * ...
	 * @author idzeir
	 */
	public class FlowerStatus 
	{
		static public const FLOWER_FULL:String = "flowerFull";
		static public const FLOWER_EMPTY:String = "flowerEmpty";
		static public const FLOWER_GETTING:String = "flowerGetting";
		
		public function FlowerStatus() 
		{
			throw new Error("静态类，不能实例化");
		}		
		
	}

}