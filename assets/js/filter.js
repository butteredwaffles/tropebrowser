var body = document.querySelector("body");
for (i = 0; i < body.children.length; i++) {
    if (body.children[i].id !== "main-container" && body.children[i].id !== "user-prefs") {
      body.children[i].parentNode.removeChild(body.children[i].previousSibling);
      body.children[i].parentNode.removeChild(body.children[i].nextSibling);
      body.children[i].parentNode.removeChild(body.children[i]);
    }
}

var ads = document.querySelectorAll(".proper-ad-unit, .ad");
for (i = 0; i < ads.length; i++) {
  ads[i].parentNode.removeChild(ads[i]);
}

var mainheader = document.querySelector("#main-header-bar");
mainheader.parentNode.removeChild(mainheader)
//mainheader.setAttribute("style", "display: none;");
body.style.marginTop = "0";
body.style.marginBottom = "0";
body.style.height = "100%";