package haxe.ui.test.irc;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.themes.DefaultTheme;

class Main {
	public static function main() {
		Toolkit.theme = new DefaultTheme();
		Toolkit.init();
		Toolkit.openFullscreen(function(root:Root) {
			root.addChild(new IRCController().view);
		});
	}
}
