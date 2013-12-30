# graze

A scraping library for node.js

Construct templates using a combination of CSS selectors and Graze extractors to transform an HTML web page into a structured Javscript object.  Templates are structured in a similar way to the DOM of the page, making them easy to understand and maintain.  Graze extractors provide a plethora of methods which can be used to find exactly the data you need from the most poorly structured of pages.  It is best explained via example, so see below.  

Graze extractors methods work just like jQuery's methods.  Pretend that `graze` is the jQuery object which matches the chain of selectors above it and construct the return value that you desire.  The corresponding key for a graze extractor value in the template is interpreted as the name by which the extractor's result will be given in the final object.  Again, this is better explained by example, so see below.  

If jQuery's methods don't quite cut it, you can define your own custom function which will be passed the matched element as its only argument, and will place the return value of your function in the finalised object.  

When a list of objects must be matched, provide a name for the list as the key and an array as the value.  The elements matched at this point in the heirarchy will be iterated over at this point, and passed into the template defined within.  Continue writing this template as an object placed within the first element of the array.  Other elements will be ignored.  Lists may be nested.  

## Example

Coffeescript:

```coffee
graze = require 'graze'

template = graze.template
    '#searchResult tr': 
        results: [
            'td:eq(1)':
                '.detName a':
                    title: graze.text()
                    link: graze.attr('href')
                '[alt="Magnet link"]':
                    magnet_link: graze.parent().attr('href')
                '.detDesc':
                    description: graze.text()
                    size: ($el) -> $el.text().match(/Size\s*([^,]*),/)?[1]
            'td:eq(2)':
                seeders: graze.text()
        ]

template.scrape('http://thepiratebay.se/search/something%20illegal/').then (results) ->
    console.log results
```

Javscript:

```javascript
var graze = require('graze');

var template = graze.template({
    '#searchResult tr': {
        results: [
            'td:eq(1)': {
                '.detName a': {
                    title: graze.text(),
                    link: graze.attr('href'),
                },
                '[alt="Magnet link"]': {
                    magnet_link: graze.parent().attr('href'),
                },
                '.detDesc': {
                    description: graze.text(),
                    size: function($el) { match = $el.text().match(/Size\s*([^,]*),/); return match && match[1] }
                },
            },
            'td:eq(2)': {
                seeders: graze.text(),
            },
        ],
    },
});

template.scrape('http://thepiratebay.se/search/something%20illegal/').then(function(results) {
    console.log(results)
});
```

Results:

```javascript
{
    "results": [ {
        "title": "Chairlift - Something",
        "link": "http://thepiratebay.se/torrent/9360343/Chairlift_-_Something",
        "magnet_link": "magnet:?xt=urn:btih:1e4dc0a30c6c413c947bd7df11bc8bd764c3babd&dn=Pure18.13.12.07.Zoey.Paige."
                     + "Something.Sweet.XXX.1080p.MP4-KTR&tr=udp%3A%2F%2Ftracker.openbittorrent."
                     + "com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole."
                     + "it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Fopen.demonii.com%3A1337",
        "description": "Uploaded 12-17 17:53, Size 39.79 MiB, ULed by Anonymous",
        "size": "39.79 MiB",
        "seeders": 1,
    }, {
        ...
    } ]
}
```
