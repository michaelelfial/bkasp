BkInit.StartMenu(function(menu){
    menu.add(   "Service server",
                "launchone ExperimentalServiceApp"
    ).appclass(
                "ExperimentalServiceApp"
    );
})
.AppData(ExperimentalServiceApp,function(ad) {
	ad.folder("texts");
	ad.folder("config");
	ad.content("texts/text1","text/plain","Hello world - a text saved in app data");
	ad.object("config/menu", { item1: "This is item 1", item2: "This is item 2" });
});