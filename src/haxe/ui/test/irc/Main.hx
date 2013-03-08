package haxe.ui.test.irc;

import haxe.ui.core.Component;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Root;
import haxe.ui.style.StyleManager;
import haxe.ui.style.windows.WindowsStyles;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

class Main extends Sprite {
	public static var WINDOWS_SKIN:String = "WINDOWS";
	
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, initialize);
	}

	private function initialize(e) {
		removeEventListener(Event.ADDED_TO_STAGE, initialize);
		startApp(WINDOWS_SKIN);
	}
	
	public static function startApp(skinId:String):Void {
		if (skinId == WINDOWS_SKIN) {
			StyleManager.styles = new WindowsStyles();
		}
		
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		Root.destroyAll();		
		var root:Root = Root.createRoot();
		root.addChild(new IRCController().view);
	}
	
	static public function main() {
		new Main().initialize(new Event(""));
	}
}
