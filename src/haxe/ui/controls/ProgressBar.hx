package haxe.ui.controls;

import nme.display.DisplayObject;
import haxe.ui.core.Component;

class ProgressBar extends Component {
	private var valueComponent:Component;
	
	private var min:Float = 0;
	private var max:Float = 100;
	public var value(default, set_value):Float = 50;
	
	public function new() {
		super();
		
		valueComponent = new Component();
		valueComponent.id = "progressBarValue";
	}
	
	//************************************************************
	//                  OVERRIDES
	//************************************************************
	public override function initialize():Void {
		super.initialize();
	
		addChild(valueComponent);
	}
	
	public override function resize():Void {
		super.resize();
		
		resizeValue();
	}

	//************************************************************
	//                  GETTERS AND SETTERS
	//************************************************************
	public function set_value(value:Float):Float {
		if (value < min) {
			value = min;
		}
		if (value > max) {
			value = max;
		}
		this.value = value;
		resizeValue();
		return value;
	}
	
	//************************************************************
	//                  HELPERS
	//************************************************************
	private function resizeValue():Void {
		if (ready == false) {
			return;
		}
		
		var m:Float = (max - min);
		var cx:Float = (innerWidth * value) / 100;
		if (cx < 0) {
			cx = 0;
		}
		if (cx > 0) {
			valueComponent.width = Std.int(cx);
			valueComponent.height = innerHeight;
			valueComponent.visible = true;
		} else {
			valueComponent.visible = false;
		}
	}
}
