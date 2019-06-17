// -------------------------------------------------------------------------------------------- Default
function CardOpener() {
    ViewBase.apply(this, arguments);
};
CardOpener.Inherit(ViewBase, "CardOpener");
CardOpener.Implement(IPlatformUtilityImpl,"systools");
CardOpener.Implement(IAjaxContextParameters);
CardOpener.prototype.favedit = false;
CardOpener.registerShellCommand("run","opener", function(args) {
	function usage() {
		return "usage: run [url|view|app <url or appclass>]";
	}
	var cmd = args.consumeParam();
	if (cmd != null) {
		var p = args.consumeParam();
		if (p == null) return "Missing argument.\n" + usage();
		if (cmd == "view" || cmd == "url") {
			Shell.openWindowedView({ url: p });
			//this.CardHistory(p);
		} else if (cmd == "app") {
			Shell.launchAppWindow(p);
		}
	} else {
		Shell.openWindowedView({ url: "/sbin/CardOpener.asp" });
	}
}, "opens a view or app, usage: run [url|view|app <url or appclass>], when used without arguments opens the UI.");
CardOpener.prototype.init = function () {
    this.reload();      // used to get the history data
    this.reloadFavs();  // used to get the favorites data
    this.inedit = false; // used when edit for a single row is pressed so the user can't edit more than one record 
    this.updateTargets();
};

CardOpener.prototype.get_caption = function () {
    return "Open view utility";
};

// -------------------------------------------------------------------------------------------- Manage (Save/ Edit) History
    // Get History From Local Storage
CardOpener.prototype.reload = function () {
    var l = localStorage.getItem('HistoryOfOpenCardCard');
    if (l != null) {
        this.history = l.split(",");
        if (this.history.length == 1) {
            if (this.history[0] == "") {
                this.history.removeElement(0);
            }
        }
    } else {
        this.history = null;
    }
};

    // Save History To Local Storage
CardOpener.prototype.SerializeHistory = function () {
    if (!IsNull(this.history)) {
        var urls = this.history;
        var urlsForHistory = urls.join(',');
        localStorage.setItem('HistoryOfOpenCardCard', urlsForHistory);
        this.updateTargets();
    }
};
    // Clear Whole history
CardOpener.prototype.OnClearHistoryClick = function() {
    localStorage.removeItem('HistoryOfOpenCardCard');
    this.reload();
    this.updateTargets();
};
    // Add New Element
CardOpener.prototype.CardHistory = function (url) {
        if (url != "") {
        if (!IsNull(this.history)) {
            if (this.history.findElement(url) == -1) {
                this.history.unshift(url);
                this.updateTargets();
                this.SerializeHistory();
            } else {
                this.history.removeElement(url);
                this.history.unshift(url);
                this.SerializeHistory();
            }
            this.updateTargets();
        } else {
            this.history = new Array();
            this.history.unshift(url);
            this.SerializeHistory();
            this.updateTargets();
        } 
    }
};
// -------------------------------------------------------------------------------------------- Favorites           Favorites Save template - (T)Title(L)Link,(T)Title(L)Link
// Get Favorites From Local Storage
CardOpener.prototype.reloadFavs = function () {
    var l = localStorage.getItem('FavoritesOfCardOpenerCardLS'); // the stored data in the Local Storage (LS)
    if (l != null) {
        ls_data = l.split(","); // The splited string from the LS
        if (ls_data.length > 0) {
            this.favorites = [];
            for (var i = 0; i < ls_data.length; i++) {
                var reg = /\(T\)(.*?)\(L\)(.*)|$/g; // this RegExp maches the - Title text as [1] and the Link text as [2]
                var s = ls_data[i].toString();
                var temp = reg.exec(s);
                if (!IsNull(temp) && !IsNull(temp[1])) {
                    this.favorites.push({ "title": temp[1], "link": temp[2] }); // this.favorites is where the array for binding is held
                }
            }
        }
    } else {
        this.favorites = null;
    }
};

    // Save Favorites To Local Storage
CardOpener.prototype.SerializeFavs = function () {
    if (!IsNull(this.favorites)) {
        var urls = this.favorites;
        var temp = [];
        for (var i = 0; i < urls.length; i++) {
            if (urls[i].title != "") {
                temp.push("(T)" + urls[i].title + "(L)" + urls[i].link);    // create a array with the united link with title that can be joined and recoded in the LS
            }
        }
        var urlsForFavorites = temp.join(',');
        localStorage.setItem('FavoritesOfCardOpenerCardLS', urlsForFavorites);
        this.updateTargets();
    }
};

// Called when the fav save image is pressed
CardOpener.prototype.SaveFavs = function (e, dc, target) {
    this.updateSources();
    this.favorites;
    if (!IsNull(this.favorites) && this.favorites.length > 0) {
        this.SerializeFavs();
        this.HideFavoritesDK();
    }
};

// Called when the fav add new image is pressed - The limit for favorites is 6 but can be changed
CardOpener.prototype.OnAddFav = function () {
    if (!IsNull(this.favorites) && this.favorites.length > 0) {
        if (this.favorites.length <= 5) {
            this.favorites.push({ "title": "", "link": "" });
            this.ShowFavoritesDK();
        } else {
            alert("The limit for Favorite links is 6!");
        }
    } else {
        this.favorites = [];
        this.favorites.push({ "title": "", "link": "" });
        this.ShowFavoritesDK();
    }
};
// Called when the fav delete image is pressed
CardOpener.prototype.OnDelFav = function (e, dc) {
    if (!IsNull(this.favorites) && this.favorites.length > 0) {
        for (var i = 0; i < this.favorites.length; i++) {
            if (this.favorites[i].title == dc.title) {
                if (this.favorites[i].link == dc.link) {
                    this.favorites.splice(i, 1);
                }
            }
        }
        this.SerializeFavs();
    }
};
// Called when the fav edit image is pressed
CardOpener.prototype.EditFavs = function () {
    this.ShowFavoritesDK();
};

// Called when the fav cancel image is pressed
CardOpener.prototype.OnFavCancel = function () {
    this.reloadFavs();
    this.HideFavoritesDK();
};
// Show edit mode in the fav section
CardOpener.prototype.ShowFavoritesDK = function () {
    this.favedit = true;
    var favedits = this.childObject("favedits");
    var faveditsrepeater = this.childObject("faveditsrepeater");
    if (!IsNull(favedits) && !IsNull(faveditsrepeater)) {
        favedits.updateTargets();
        faveditsrepeater.updateTargets();
    }
};
// Hide edit mode in the fav section
CardOpener.prototype.HideFavoritesDK = function () {
    this.favedit = false;
    var favedits = this.childObject("favedits");
    var faveditsrepeater = this.childObject("faveditsrepeater");
    if (!IsNull(favedits) && !IsNull(faveditsrepeater)) {
        favedits.updateTargets();
        faveditsrepeater.updateTargets();
    }
};
// -------------------------------------------------------------------------------------------- Open Link
    // Detect Enter In Textbox
CardOpener.prototype.onKeypress = function (e, dc) {
    if (e.which == 13 || e.which == 32) {
        e.preventDefault();
        this.OnOpenCard(e, dc);
    }
};
    // Open Card
CardOpener.prototype.OnOpenCard = function (e, dc) {
    var scope = this.childObject("cardopener");
    scope.updateSources();
    if (dc.url != null || dc.url <= 0) {
        dc.url = dc.url.replace(/\s/g, '');
        var url = mapPath(dc.url);
        Shell.openWindowedView({ url: url });
        this.CardHistory(url);
    }
};

    // Move Opended Element From History To Top
CardOpener.prototype.HistoryOpen = function (e, url, el) {
    if (url != "") {
        if (!IsNull(this.history)) {
            if (this.history[0] != url) {
                this.history.removeElement(url);
                this.history.unshift(url);
                this.SerializeHistory();
            }
        }
    } 
};

// -------------------------------------------------------------------------------------------- Edit History
    // Delete Current Element
CardOpener.prototype.DeleteCurrent = function (e, dc, el) {
    if (!IsNull(el)) {
        this.history.removeElement(dc);
        this.SerializeHistory();
    }
};
    // Edit Currnet Element
CardOpener.prototype.EditCurrent = function (e, dc, el) {
    if (!this.inedit) {
        if (!IsNull(el)) {
            var s = $($(el)[0].$target).parent().parent();
            if (!IsNull(s)) {
                this.inedit = true;
                s.find("span").hide();
                s.find(".c_card_opener_img_edit").hide();
                s.find("input.c_card_opener_edit").show();
                s.find(".c_card_opener_img_save").show();
            }
        }
    }
};

//// need to be fixed to work better
    // Show Pencil Image
CardOpener.prototype.OnRowHover = function (e, dc, el) {
    var s = $(el.$target);
    var edit = s.find(".c_card_opener_img_save").css("display");
    if (edit == "none") {
        s.find(".c_card_opener_img_edit").css("visibility", "visible");
    };
};
    // Hide Pencil Image
CardOpener.prototype.OnRowHoverout = function (e, dc, el) {
    var s = $(el.$target);
    s.find(".c_card_opener_img_edit").css("visibility", "hidden");
};
////////////
    // Save Edits To Curent Row
CardOpener.prototype.OnRowSave = function (e, dc, el, idx) {
    if (!IsNull(el)) {
        this.inedit = false;
        this.updateSources();
        var hist = this.child("edit_field");
        for (var i = 0; i < this.history.length; i++) {
            if (this.history[i] == dc) {
                this.history[i] = hist[i].value;
            }
        }
        var s = $($(el)[0].$target).parent();
        s.find("span").show();
        s.find("input.c_card_opener_edit").hide();
        s.find(".c_card_opener_img_save").hide();
        this.SerializeHistory();
    }
};
// Cancel Edits To Curent Row
CardOpener.prototype.OnRowCancel = function (e, dc, el) {
    if (!IsNull(el)) {
        this.inedit = false;
        var s = $($(el)[0].$target).parent().parent();
        s.find("span").show();
        s.find("input.c_card_opener_edit").hide();
        s.find(".c_card_opener_img_save").hide();
        this.updateTargets();
    }
};
// --------------------------------------------------------------------------------------------  Execute commands
    // Execute Comand On Enter
CardOpener.prototype.OnExecuteKeyCommand = function (e) {
    if (e.which == 13) {
        this.OnExecuteCommand();
    }
};
    // Execute Command On Button
CardOpener.prototype.OnExecuteCommand = function () {
    var commandText = $(this.childObject('commandtext')).val();
    CommandProccessor.Default.executeCommand(commandText);
};


// --------------------------------------------------------------------------------------------  Obsolete


CardOpener.prototype.OnCardOpened = function (sender, url) {
    alert(url);
};

CardOpener.prototype.OnEditLine = function (e, dc, binding) {
    var o = binding.container();
    if (o != null) {
        var els = o.getBindingTargets("editme|meme&toto");
        els.removeAttr("disabled");
    }
};

CardOpener.prototype.onKeypress1 = function (e) {
    if (e.which == 13 || e.which == 32) {
        e.preventDefault();
        var co = this.childObject("cardopener");
        co.updateSources();
        this.OnOpenCard(e, co.get_data());
    }
};