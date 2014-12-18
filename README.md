# graze

A simple template-based web scraping library for node.js

Web scraping is a process which can leave even the most hardy developer with an unshakable feeling of disgust.  Graze tries to make web scraping as undisgusting as possible, by letting you construct a template that just takes a URL in, and gives a well structured Javascript object out.  

## Quickstart

It's easiest to understand how it all works by looking at an example (in Coffeescript, if you don't mind).  

```coffee
graze = require 'graze'

template = graze.template {
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
}

# Simple usage
template.scrape('http://thepiratebay.se/search/something%20illegal/').then (data) ->
    console.log data

# Advanced usage
template.scrape
  uri: 'https://securewebsite.com/user/transactions'
  auth:
    username: 'admin'
    password: 'itsasecret'
.then (data) ->
    console.log data
.catch ({error, response, body}) ->
    # Handle error

###
Output on success:

{
    "results": [ {
        "title": "Chairlift - Something",
        "link": "http://thepiratebay.se/torrent/9360343/Chairlift_-_Something",
        "magnet_link": "magnet:?xt=urn:btih:1e4dc0a30c6c413c947bd7df11bc8bd764c3babd",
        "description": "Uploaded 12-17 17:53, Size 39.79 MiB, ULed by Anonymous",
        "size": "39.79 MiB",
        "seeders": 1,
    }, {
        ...
    } ]
}
###
```

A template is just a Javascript object, structured hierarchically in a way similar to the HTML you're trying to scrape.  The keys and values of the objects that make up this template have special meanings.  There are two kinds of values that keys can take on:

- **A CSS Selector**: This changes the scope of the template that follows.  At first the entire web page is within scope, but when a CSS selector is encountered as a key, the template contained has only the elements which match this CSS selector in its scope.  The value under a CSS selector in a template is simply another template.  
- **A name**: This specifies a key that will be used in the output object to store information.  The value under a name in a template can be one of the following things, each which determine its output value:
    - **An array**: This creates an iterator which will apply a template to all elements within scope.  The actual array passed in here is only of length 1, and contains the template which will be used on each element.  The final result will be an array containing the information scraped from each iterated element.  
    - **A graze extractor**: This defines how to extract information from the HTML.  They might look familiar if you've used jQuery.  Pretend that the `graze` module is a jQuery object containing the elements in scope.  Whatever chain of methods you call here will be repeated on the web page's in-scope elements, and the final result will appear in the output object under the above name. 
    - **A function**: A function which takes in a jQuery object, and returns the desired information.  Use a function if a graze extractor doesn't quite cut it.  If you need to get fancy, you can have the function take in two arguments, like `($el, $)`, which gives you direct access to jQuery's `$`.  

Scraping a website is as simple as calling the `template.scrape` function above.  It takes the same first argument as the `request` function in the popular library [request](https://www.npmjs.org/package/request).  It returns a [q](https://www.npmjs.org/package/q) promise object, which helps to stop pyramids of death and makes error handling far more sane.  

## Pro tips

### Nesting templates

You might find yourself in a situation where you'd like to group properties together within a parent object, to give something like:

```javascript
{
    ...
    "properties": {
        "size": "1.2GB",
        "upload_date": "11/11/2011"
    },
    ...
}
```

This can be achieved using the special `graze.nest(template)` function, which takes in a template and returns a custom function.  This function takes in the current page scope and processes it using the given template, returning that as its extracted value.  So to achieve the above, you might create a template like:

```coffee
graze.template {
    ...
    'properties': graze.nest
        '.detDesc':
            size: ($el) -> $el.text().match(/Size\s*([^,]*),/)?[1]
            upload_date: ($el) -> $el.text().match(/Uploaded ([^,]*),/)?[1]
    ...
}
```

### Accessing the response object

Custom functions are called with the request's `response` object as their context, so you can access things like the URL of the page being scraped as `this.request.href`.  

### Processing HTML directly

If you'd rather not have `graze` handle your web-page retrieval, you can manually run a template on an HTML string by calling `template.process(html, context)`, where `context` is the context you wish your custom functions to run within.  

# Javascript example

For those of you who prefer decaf:

```javascript
var graze = require('graze');

var template = graze.template({
    '#searchResult tr': {
        results: [{
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
        }],
    },
});

template.scrape({
    uri: 'https://securewebsite.com/user/transactions',
    auth: {
        username: 'admin',
        password: 'itsasecret',
    },
}).then(function(data) {
    console.log(data)
}).fail(function(data) {
    console.error(data.error, data.response, data.body)
});
```
