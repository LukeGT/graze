# graze

A scraping library for node.js

*Note: This doesn't work at all yet.*

Construct templates using a combination of CSS queries and graze extractors to transform an HTML web page into a structured Javscript object.  Templates mimic the structure of the page, making them easy to understand and maintain.  Graze extractors provide a plethora of methods which can be used to find exactly the data you need from the most poorly structured of pages.  

## Example

Coffeescript:

    graze = require 'graze'

    template = graze.template
        '#searchResult tr': 
            results: [
                'td:eq(1)':
                    '.detName a':
                        title: graze.text()
                        '&':
                            link: graze.attr('href')
                    '[alt="Magnet link"]':
                        magnet_link: graze.parent().attr('href')
                    '.detDesc':
                        description: graze.text()
                        size: graze.text().regex(/Size\s*([^,]*),/)
                'td:eq(2)':
                    seeders: graze.text()
            ]

    results = template.scrape('http://thepiratebay.se/search/something%20illegal/')

Javscript:

    var graze = require('graze');

    var template = graze.template({
        '#searchResult tr': {
            results: [
                'td:eq(1)': {
                    '.detName a': {
                        title: graze.text(),
                        '&': {
                            link: graze.attr('href'),
                        },
                    },
                    '[alt="Magnet link"]': {
                        magnet_link: graze.parent().attr('href'),
                    },
                    '.detDesc': {
                        description: graze.text(),
                        size: graze.text().regex(/Size\s*([^,]*),/),
                    },
                },
                'td:eq(2)': {
                    seeders: graze.text(),
                },
            ],
        },
    });

    results = template.scrape('http://thepiratebay.se/search/something%20illegal/')

Results:

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