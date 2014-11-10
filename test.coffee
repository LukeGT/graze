graze = require './index'
vows = require 'vows'

vows.describe('Functional Tests').addBatch

    'when looking at pirate bay':

        topic: graze.template
            '#searchResult > tr':
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

        'and scraping a search for something':
            topic: (template) -> template.scrape('http://thepiratebay.se/search/something').then @callback

            'we get sensible data': (data) ->
                data.should.be.ok
                

test.scrape('http://thepiratebay.se/search/something')
.then (results) ->
    console.log results

test.scrape('bad url')
.then (results) ->
    console.log 'test failed bad url'
.catch ({error, response}) ->
    console.log 'pass bad url:', error, response

test.scrape('http://www.thisurldoesntexistoritbetterwellnotorelsethistestisbad.com/')
.then (results) ->
    console.log 'test failed non-existant'
.catch ({error, response}) ->
    console.log 'pass non-existant:', error, response

test.scrape('https://github.com/this/doesnt-exist')
.then (results) ->
    console.log 'test failed non-200'
.catch ({error, response}) ->
    console.log 'pass non-200:', error, response
