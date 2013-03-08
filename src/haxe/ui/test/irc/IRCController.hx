package haxe.ui.test.irc;

import haxe.ui.containers.ListView;
import haxe.ui.containers.TabView;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;
import haxe.ui.popup.Popup;
import native.events.MouseEvent;

class IRCController extends Controller {
	public function new() {
		super(ComponentParser.fromXMLAsset("ui/irc.xml"));
		
		attachEvent("createConnectionButton", MouseEvent.CLICK, onCreateConnection);
	}

	private function onCreateConnection(event:MouseEvent):Void {
		var controller:ConnectionPopupController = new ConnectionPopupController();
		var createConnectionPopup:Popup = Popup.showCustom(view.root, controller.view, "New Connection", true);
		controller.attachEvent("cancelButton", MouseEvent.CLICK, function (e) {
			Popup.hidePopup(createConnectionPopup);
		});
		
		controller.attachEvent("connectButton", MouseEvent.CLICK, function (e) {
			var server:String = controller.getComponent("server").text;
			var channel:String = controller.getComponent("channel").text;
			var nickname:String = controller.getComponent("nickname").text;
			
			var irc:SimpleIRCClient = new SimpleIRCClient();
			var connectingPopup:Popup = null;
			irc.addEventListener(IRCEvent.CONNECTED, function (e) {
				trace("connected");
				irc.login(nickname);
			});
			irc.addEventListener(IRCEvent.LOGGED_IN, function (e) {
				trace("logged in");
				irc.join(channel);
			});
			irc.addEventListener(IRCEvent.JOINED_CHANNEL, function (e) {
				trace("joined");
				Popup.hidePopup(connectingPopup);
				Popup.hidePopup(createConnectionPopup);
				var tabController:IRCTabController = new IRCTabController(irc);
				getComponentAs("mainTabs", TabView).addPage(channel, tabController.view);
			});
			irc.addEventListener(IRCEvent.ERROR, function (e:IRCEvent) {
				Popup.hidePopup(connectingPopup);
				Popup.showSimple(view.root, e.data, "Error", true);
				trace("error");
			});
			connectingPopup = Popup.showBusy(view.root, "Connecting, please wait...");
			irc.connect(server);
		});
	}
}