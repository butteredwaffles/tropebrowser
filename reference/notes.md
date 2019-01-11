# Universal Info

Each element in the main article will probably have to be traversed individually in order to get all the links and such formatted correctly.
The selector for this is `#main-article *`.

## Main Pages

### Article Titles
There are other titles, but this is the only one that omits the ` - TV Tropes` at the end.

`<h1 itemprop="headline" class="entry-title">Camera Abuse</h1>`

### Subpage Links
Parent selector is `.subpage_links`, which is a `ul` containing all these links. It also contains the "create links" list, so using `.subpage_link` is a better selector in order to avoid catching pages that don't actually exist.
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
They do, of course, have a lot of inner links that will have to be formatted. `<em>` tags will have to be handled as well in order to ensure
the text is italicised.
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
