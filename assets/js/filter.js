var body = document.querySelector("body");
for (i = 0; i < body.children.length; i++) {
    if (body.children[i].id !== "main-container" && body.children[i].id !== "user-prefs") {
        try {
            body.children[i].parentNode.removeChild(body.children[i].previousSibling);
            body.children[i].parentNode.removeChild(body.children[i].nextSibling);
            body.children[i].parentNode.removeChild(body.children[i]);
        }
        catch (error) {
            // welp.
        }
    }
}

var ads = document.querySelectorAll(".proper-ad-unit, .ad");
for (i = 0; i < ads.length; i++) {
    ads[i].parentNode.removeChild(ads[i]);
}

var mainheader = document.querySelector("#main-header-bar");
mainheader.parentNode.removeChild(mainheader)

var createNewSubpage = document.querySelector(".create-subpage");
createNewSubpage.parentNode.removeChild(createNewSubpage);

var mobileActions = document.querySelector(".mobile-actionbar-toggle");
mobileActions.parentNode.removeChild(mobileActions);

body.style.marginTop = "0";
body.style.marginBottom = "0";
body.style.height = "100%";