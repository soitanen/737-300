var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/737-300/Systems/737-AP-dlg.xml");
var radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/737-300/Dialogs/737-radio.xml");
				
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");
gui.menuBind("radio", "dialogs.radio.open()");