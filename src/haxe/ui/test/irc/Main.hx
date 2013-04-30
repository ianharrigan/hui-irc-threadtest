package haxe.ui.test.irc;

import haxe.ui.containers.ListView;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;
import haxe.ui.core.Globals;
import haxe.ui.core.Root;
import haxe.ui.resources.ResourceManager;
import haxe.ui.style.StyleManager;
import haxe.ui.test.irc.IRCController;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

class Main extends Sprite {
	public static var WINDOWS_SKIN:String = "windowsTheme";
	public static var ANDROID_SKIN:String = "androidTheme";
	public static var GRADIENT_SKIN:String = "gradientTheme";
	
	var inited:Bool;

	/* ENTRY POINT */
	function resize(e) {
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() {
		#if android
			var skinId:String = ANDROID_SKIN;
		#else
			ResourceManager.defaultResType = "embedded";
			var skinId:String = WINDOWS_SKIN;
		#end
		
		if (inited) return;
		inited = true;
		
		Globals.reset();
		Globals.add(skinId);
		Globals.add("en_UK");
		#if flash Globals.add("flash"); #end
		#if html5 Globals.add("html5"); #end
		#if windows Globals.add("windows"); #end
		#if neko Globals.add("neko"); #end
		#if android Globals.add("android"); #end
		
		StyleManager.clear();
		if (skinId == WINDOWS_SKIN) {
			StyleManager.loadFromResource("skins/windows/windows.css");
			StyleManager.loadFromResource("skins/windows/buttons.css");
			StyleManager.loadFromResource("skins/windows/tabs.css");
			StyleManager.loadFromResource("skins/windows/listview.css");
			StyleManager.loadFromResource("skins/windows/scrolls.css");
			StyleManager.loadFromResource("skins/windows/popups.css");
			StyleManager.loadFromResource("skins/windows/sliders.css");
		} else if (skinId == ANDROID_SKIN) {
			StyleManager.loadFromResource("skins/android/android.css");
			StyleManager.loadFromResource("skins/android/buttons.css");
			StyleManager.loadFromResource("skins/android/tabs.css");
			StyleManager.loadFromResource("skins/android/listview.css");
			StyleManager.loadFromResource("skins/android/scrolls.css");
			StyleManager.loadFromResource("skins/android/popups.css");
			StyleManager.loadFromResource("skins/android/sliders.css");
		} else if (skinId == GRADIENT_SKIN) {
			StyleManager.loadFromResource("skins/gradient/gradient.css");
		}
		
		var stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;

		Root.destroyAll();
		var root:Root = Root.createRoot();
		var controller:Controller = new IRCController();
		root.addChild(controller.view);
	}

	/* SETUP */
	public function new() {
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) {
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() {
		// static entry point
		Lib.current.stage.align = nme.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
