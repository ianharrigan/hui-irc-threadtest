package haxe.ui.test.irc;

import haxe.ui.core.Controller;
import haxe.ui.core.ComponentParser;

class ConnectionPopupController extends Controller {
	public function new() {
		super(ComponentParser.fromXMLAsset("ui/createConnectionPopup.xml"));
	}
}