package haxe.ui.test.irc;

import flash.Lib;
import haxe.ui.toolkit.core.Controller;
import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.RootManager;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.resources.ResourceManager;
import haxe.ui.toolkit.style.StyleManager;

class Main {
	private static var STYLE_WINDOWS:String = "windows";
	private static var STYLE_GRADIENT:String = "gradient";
	private static var STYLE_GRADIENT_MOBILE:String = "gradient mobile";
	
	public function new() {
		var root:Root = RootManager.instance.createRoot( { x: 0, y: 0, percentWidth: 100, percentHeight: 100 }, function(root:Root) {
			var controller:Controller = new IRCController();
			root.addChild(controller.view);
		});
	}
	
	public static function openApp(style:String):Void {
		StyleManager.instance.clear();
		ResourceManager.instance.reset();
		
		if (style == STYLE_GRADIENT) {
			Macros.addStyleSheet("styles/gradient/gradient.css");
		} else if (style == STYLE_GRADIENT_MOBILE) {
			Macros.addStyleSheet("styles/gradient/gradient_mobile.css");
		} else if (style == STYLE_WINDOWS) {
			Macros.addStyleSheet("styles/windows/windows.css");
			Macros.addStyleSheet("styles/windows/buttons.css");
			Macros.addStyleSheet("styles/windows/tabs.css");
			Macros.addStyleSheet("styles/windows/listview.css");
			Macros.addStyleSheet("styles/windows/scrolls.css");
			Macros.addStyleSheet("styles/windows/sliders.css");
		}
		
		var main = new Main();
	}
	
	public static function main() {
		Toolkit.init();
		
		#if android
			openApp(STYLE_GRADIENT_MOBILE);
		#else
			openApp(STYLE_GRADIENT);
		#end
	}
}
