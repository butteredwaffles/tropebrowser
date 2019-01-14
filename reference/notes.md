# Universal Info

Each element in the main article will probably have to be traversed individually in order to get all the links and such formatted correctly.
The selector for this is `#main-article *`.

The selector `.ad-unit` is the `div` that contains all the ads. This will have to be filtered.

## Main Pages

### Article Titles
There are other titles, but this is the only one that omits the ` - TV Tropes` at the end.

`<h1 itemprop="headline" class="entry-title">Camera Abuse</h1>`

### Subpage Links
Parent selector is `.subpage-links`, which is a `ul` containing all these links. It also contains the "create links" list, so using `.subpage_link` is a better selector in order to avoid catching pages that don't actually exist.
Important to note that the page name ("Main") is the text of the `wrapper` span. The `spi` span is empty.
```
<li>
  <a href="/pmwiki/pmwiki.php/Main/CameraAbuse" class="subpage-link curr-subpage" title="The Main page">
    <span class="wrapper">
      <span class="spi main-page"></span>Main
    </span>
  </a>
</li>
```

### Article Images
`quoteright` is the head image, while `acaptionright` is the quote beneath it, oddly. Not every article has both, and some only have one or the other.
There is only maximum one each per article despite being in a class. When both exist, [this](https://github.com/flutter/flutter/issues/2022#issuecomment-376370973)
solution will have to be used in order to get it to flow around the text like it does on the website. Of course, if that turns out not to be possible,
we could just place them in a `Column` widget so they're in a line.
```
<div class="quoteright" style="width:350px;">
  <a class="twikilink" href="/pmwiki/pmwiki.php/Manga/HaruhiChan" title="/pmwiki/pmwiki.php/Manga/HaruhiChan">
    <img src="https://static.tvtropes.org/pmwiki/pub/images/haruhi_camera_abuse.jpg" class="embeddedimage" border="0" alt="https://static.tvtropes.org/pmwiki/pub/images/haruhi_camera_abuse.jpg">
  </a>
</div>
<div class="acaptionright" style="width:350px;">Ouch, now
    <a class="twikilink" href="/pmwiki/pmwiki.php/Main/ThatsGottaHurt" title="/pmwiki/pmwiki.php/Main/ThatsGottaHurt">That's Gotta Hurt</a>.
</div>
```

### Body
Nothing special about these tags. They are just `p` tags underneath the `#main-article` tag. No class or anything.
They do, of course, have a lot of inner links that will have to be formatted. 
```
<p>
  <em>
    <a class="twikilink" href="/pmwiki/pmwiki.php/Main/SelfDemonstratingArticle" title="/pmwiki/pmwiki.php/Main/SelfDemonstratingArticle">(Start shaking your monitor now.)</a>
  </em>
</p>
<p>How does one show that the on-screen action is getting out of control? By having it hit the camera! The entire screen will <a class="twikilink" href="/pmwiki/pmwiki.php/Main/JitterCam" title="/pmwiki/pmwiki.php/Main/JitterCam">shake</a>, or be obscured by gunk or debris. If the impact is really bad, it will crack the lens or even break the camera, treating the audience to a screenful of static.</p>
```

### Secondary Subpage Links
Articles with many, many examples have their own category pages. These appear to be in a regular `<strong>` tag, which may be problematic
to deal with. How to deal with parsing the pages themselves is dealt with in the [Subpage](#Subpages) section.
```
<strong>Examples with their own sub-page:</strong>
<ul>
  <li>
    <a class="twikilink" href="/pmwiki/pmwiki.php/CameraAbuse/Film" title="/pmwiki/pmwiki.php/CameraAbuse/Film">Film</a>
  </li>
  <li>
    <a class="twikilink" href="/pmwiki/pmwiki.php/CameraAbuse/LiveActionTV" title="/pmwiki/pmwiki.php/CameraAbuse/LiveActionTV">Live-Action TV</a>
  </li>
  <li>
    <a class="twikilink" href="/pmwiki/pmwiki.php/CameraAbuse/VideoGames" title="/pmwiki/pmwiki.php/CameraAbuse/VideoGames">Video Games</a>
  </li>
  <li>
    <a class="twikilink" href="/pmwiki/pmwiki.php/CameraAbuse/WesternAnimation" title="/pmwiki/pmwiki.php/CameraAbuse/WesternAnimation">Western Animation</a>
  </li>
</ul>
```

## Special Tags
Trope lists and body paragraphs can contain `em` tags, `strong` tags, and of course, links. Each node traversed in this application will have to be tested for these. There is a class `indent` that will use two `\t` characters to emulate.

`document.querySelectorAll("#main-article p, #main-article p+*:not(div):not(hr), #main-article > .indent")`

```
<div class="indent">
  <em>"Sorry, baby! Why you make me do that?"</em>
  <div class="indent">
    &mdash;Description of the "Double Slap" weapon from 
    <em>
      <a class="twikilink" href="/pmwiki/pmwiki.php/VideoGame/Disgaea2CursedMemories" title="/pmwiki/pmwiki.php/VideoGame/Disgaea2CursedMemories">Disgaea 2: Cursed Memories</a>
    </em>
  </div>
</div>
```


### Folders
The label is the `div` before the actual folder, which makes this a little obnoxious. The folder itself is a simple `div` with a `ul` inside.
The `li`s' text in the `ul` can probably be parsed similarly to the body's `p` tags, although some special formatting will need to be done to
show/hide the folders. We could use [GestureDetector](http://cogitas.net/implement-gesturedetector-flutter/) to insert a `ListView.builder` that creates the list items into the widget list.
```
<div id="folder1" class="folder" isfolder="true" style="display:block;">
  <ul>
    <li>In Episode 4 of<em><a class="twikilink" href="/pmwiki/pmwiki.php/LightNovel/BokuWaTomodachiGaSukunai" title="/pmwiki/pmwiki.php/LightNovel/BokuWaTomodachiGaSukunai">Boku wa Tomodachi ga Sukunai</a>NEXT</em>, after riding a wild roller coaster too many times, both Sena and Yozora <a class="twikilink" href="/pmwiki/pmwiki.php/Main/VomitIndiscretionShot" title="/pmwiki/pmwiki.php/Main/VomitIndiscretionShot">throw up</a> directly on the camera lens (and all over Kodoka).</li>
    <li>The opening credits of <em> <a class="twikilink" href="/pmwiki/pmwiki.php/Manga/DetroitMetalCity" title="/pmwiki/pmwiki.php/Manga/DetroitMetalCity">Detroit Metal City</a></em> end with Krauser II seizing the camera and spinning it violently around to face... the show's logo.</li>
    ...
  </ul>
</div>
```

### Spoilers
Spoilers are a `span` tag with the class `spoiler`. On tap, these reveal the text beneath them. Flutter has a [GestureDetector](https://dev.to/rkowase/how-to-add-a-click-event-to-any-widget-of-flutter-2len)
widget that will allow us to do this without a button.
```
<span class="spoiler" title="you can set spoilers visible by default on your profile">Minoru finally snaps</span>
```


## Subpages
`#main-article` holds all the information, just like it does for main pages.
Category headers are classless `h2` tags, although they are occasionally omitted. Following them are untagged `ul`s,
with `li`s that can be filtered through the same measure as all other `li`s.

```
<h2>Films - Animated</h2>
<ul>
    <li>Disney's
      <em>
        <a class="twikilink" href="/pmwiki/pmwiki.php/Disney/Aladdin" title="/pmwiki/pmwiki.php/Disney/Aladdin">Aladdin</a>
      </em>: The narrator in the prologue entreats the audience "Please, please, come closer!" Then the camera zooms right up to his face, and he mutters "Too close, a little too close!"
    </li>
    ...
</ul>
```

## Searches
The URL for searches is `"https://tvtropes.org/pmwiki/elastic_search_result.php?q=${search_term}&page_type=all&search_type=article`.
Search results are `a` tags with the class `.search-result`. The title selecter is `font-l`. If an image is present, there will be a div under the container `div` called `.img-wrapper` containing an `img` tag. The container `div` contains the preview text. The "More" button can be ignored, as I don't think that will be implemented.

```
<a href="/pmwiki/pmwiki.php/Main/CameraAbuse" class="search-result">
  <p class="elastic-search-result-crumbs font-l mobile-font-m bold">
    <i class='fa fa-chevron-right'></i>
    Camera Abuse
  </p>
  <div>
    <div class="img-wrapper">
       <img class="elastic-search-result-image" src="http://static.tvtropes.org/pmwiki/pub/images/haruhi_camera_abuse.jpg">
    </div>
    ultimately need to be replaced. All the same, some filmmakers and showrunners will use <span class="highlight">camera</span>
    shaking or other <span class="highlight">abuse</span>
    intentionally, sometimes Played...
    <span class="more-button">More <i class="fa fa-angle-double-right"></i></span>
 </div>
</a>
```
