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

# pirate_bay_template.scrape('http://thepiratebay.se/search/something').then (data) ->
#     console.log data
# .done()

vows.describe('Functional Tests').addBatch

    'when looking at pirate bay':

        topic: pirate_bay_template

        'and scraping a search for something':

            topic: (template) ->
                template.scrape('http://thepiratebay.se/search/something')
                .then (data) => @callback null, data
                .done()
                return undefined

            'we get sensible data': (data) ->
                console.log 'great success'
                # should(data).be.ok

        'and trying to hit a malformed URL':

            topic: (template) ->
                template.scrape('bad url')
                .catch (data) => @callback null, data
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                console.log "Error! Yay!"
                # should(error).be.true

        "and trying to hit a URL that doesn't exist":

            topic: (template) ->
                template.scrape('http://www.thisurldoesntexistoritbetterwellnotorelsethistestwillfail.com/')
                .catch (data) => @callback null, data
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                console.log "ERROR!!!"
                # should(error).be.true

        "and trying to hit a path that doesn't exist":

            topic: (template) ->
                template.scrape('https://github.com/this/doesnt-exist')
                .catch (data) => @callback null, data
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                console.log "ERROR!!!"
                # should(error).be.false
                # should(response.statusCode).equal(404)

.export(module)