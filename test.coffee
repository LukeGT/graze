graze = require './index'
vows = require 'vows'
should = require 'should'

pirate_bay_template = graze.template
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

vows.describe('Functional Tests').addBatch

    'when looking at pirate bay':

        topic: pirate_bay_template

        'and scraping a search for something':

            topic: (template) ->
                template.scrape('http://thepiratebay.se/search/something')
                .then @callback
                .done()
                return undefined

            'we get sensible data': (data) ->
                should(data).be.ok
                data.results.should.be.ok
                data.results[0].title.should.be.ok
                data.results[0].link.should.be.ok
                data.results[0].magnet_link.should.be.ok
                data.results[0].description.should.be.ok
                data.results[0].size.should.be.ok
                data.results[0].seeders.should.be.ok

        'and trying to hit a malformed URL':

            topic: (template) ->
                template.scrape('bad url')
                .catch @callback
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                should(error).be.ok

        "and trying to hit a URL that doesn't exist":

            topic: (template) ->
                template.scrape('http://www.thisurldoesntexistoritbetterwellnotorelsethistestwillfail.com/')
                .catch @callback
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                # should(error).be.ok

        "and trying to hit a path that doesn't exist":

            topic: (template) ->
                template.scrape('https://github.com/this/doesnt-exist')
                .catch @callback
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                should(error).be.null
                should(response.statusCode).equal(404)

.run
    error: false
