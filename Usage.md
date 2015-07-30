### Contents ###



---


# hexagonlib parts #
The hexagonlib is split into two different parts, the **base library** which contains classes that are available for any Flash-related runtime that supports ActionScript 3, and the **AIR library** which contains classes that are only available for the Adobe AIR runtime. You can use only the base library if nothing else is required but to use the AIR library you also have to link the base library since the AIR library is based on it.


---


# Setting the stage reference #
Many of the classes in hexagonlib require a reference to the stage of your main SWF. To use these classes you need to set the **stage property** of the singleton _StageReference_ class. It is recommended to do this as early as the stage is available in your application, e.g.:

```
package 
{
	import flash.display.Sprite;
	import com.hexagonstar.display.StageReference;
	
	public class Main extends Sprite
	{
		public function Main()
		{
			StageReference.stage = stage;
		}
	}
}
```