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

html = """
<html>
<table id="searchResult">
    <thead id="tableHead">
        <tr class="header">
            <th><a href="/search/something/0/13/0" title="Order by Type">Type</a></th>
            <th><div class="sortby"><a href="/search/something/0/1/0" title="Order by Name">Name</a> (Order by: <a href="/search/something/0/3/0" title="Order by Uploaded">Uploaded</a>, <a href="/search/something/0/5/0" title="Order by Size">Size</a>, <span style="white-space: nowrap;"><a href="/search/something/0/11/0" title="Order by ULed by">ULed by</a></span>, <a href="/search/something/0/8/0" title="Order by Seeders">SE</a>, <a href="/search/something/0/9/0" title="Order by Leechers">LE</a>)</div><div class="viewswitch"> View: <a href="/switchview.php?view=s">Single</a> / Double&nbsp;</div></th>
            <th><abbr title="Seeders"><a href="/search/something/0/8/0" title="Order by Seeders">SE</a></abbr></th>
            <th><abbr title="Leechers"><a href="/search/something/0/9/0" title="Order by Leechers">LE</a></abbr></th>
        </tr>
    </thead>
    <tr>
        <td class="vertTh">
            <center>
                <a href="/browse/100" title="More from this category">Audio</a><br>
                (<a href="/browse/101" title="More from this category">Music</a>)
            </center>
        </td>
        <td>
<div class="detName">           <a href="/torrent/9153823/A_Great_Big_World_-_Say_Something_(feat._Christina_Aguilera)_[Po" class="detLink" title="Details for A Great Big World - Say Something (feat. Christina Aguilera) [Po">A Great Big World - Say Something (feat. Christina Aguilera) [Po</a>
</div>
<a href="magnet:?xt=urn:btih:d6b570cf93aa3ca6edb25d689aaea74392dce0b4&amp;dn=A+Great+Big+World+-+Say+Something+%28feat.+Christina+Aguilera%29+%5BPo&amp;tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&amp;tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&amp;tr=udp%3A%2F%2Ftracker.istole.it%3A6969&amp;tr=udp%3A%2F%2Fopen.demonii.com%3A1337" title="Download this torrent using magnet"><img src="/static/img/icon-magnet.gif" alt="Magnet link"></a><img src="/static/img/icon_comment.gif" alt="This torrent has 3 comments." title="This torrent has 3 comments."><img src="/static/img/11x11p.png">
            <font class="detDesc">Uploaded 11-06&nbsp;2013, Size 8.81&nbsp;MiB, ULed by <a class="detDesc" href="/user/50XTPB/" title="Browse 50XTPB">50XTPB</a></font>
        </td>
        <td align="right">720</td>
        <td align="right">4</td>
    </tr>
    <tr>
        <td class="vertTh">
            <center>
                <a href="/browse/100" title="More from this category">Audio</a><br>
                (<a href="/browse/101" title="More from this category">Music</a>)
            </center>
        </td>
        <td>
<div class="detName">           <a href="/torrent/11230874/Foo_Fighters_-_Something_From_Nothing_-_Single_(From_Sonic_Highw" class="detLink" title="Details for Foo Fighters - Something From Nothing - Single (From Sonic Highw">Foo Fighters - Something From Nothing - Single (From Sonic Highw</a>
</div>
<a href="magnet:?xt=urn:btih:ef29df8edf434e694a2d4d3c088346208eaee5d1&amp;dn=Foo+Fighters+-+Something+From+Nothing+-+Single+%28From+Sonic+Highw&amp;tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&amp;tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&amp;tr=udp%3A%2F%2Ftracker.istole.it%3A6969&amp;tr=udp%3A%2F%2Fopen.demonii.com%3A1337" title="Download this torrent using magnet"><img src="/static/img/icon-magnet.gif" alt="Magnet link"></a><img src="/static/img/icon_image.gif" alt="This torrent has a cover image" title="This torrent has a cover image"><img src="/static/img/11x11p.png"><img src="/static/img/11x11p.png">
            <font class="detDesc">Uploaded 10-17&nbsp;06:52, Size 11.33&nbsp;MiB, ULed by <a class="detDesc" href="/user/simpsonrony/" title="Browse simpsonrony">simpsonrony</a></font>
        </td>
        <td align="right">316</td>
        <td align="right">5</td>
    </tr>
</table>
</html>
"""

okay_data = (data) ->
    should(data).be.ok
    data.results.should.be.ok
    data.results[0].title.should.be.ok
    data.results[0].link.should.be.ok
    data.results[0].magnet_link.should.be.ok
    data.results[0].description.should.be.ok
    data.results[0].size.should.be.ok
    data.results[0].seeders.should.be.ok

vows.describe('Functional Tests').addBatch

    'when looking at pirate bay':

        topic: pirate_bay_template

        'and scraping a search for something':

            topic: (template) ->
                template.scrape('http://thepiratebay.se/search/something')
                .then @callback
                .done()
                return undefined

            'we get sensible data': okay_data

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
                should(error).be.ok

        "and trying to hit a path that doesn't exist":

            topic: (template) ->
                template.scrape('https://github.com/this/doesnt-exist')
                .catch @callback
                .done()
                return undefined

            'it should fail': ({error, response}) ->
                should(error).be.null
                should(response.statusCode).equal(404)

        'and running the template on some HTML':

            topic: (template) ->
                template.process(html)

            'we get sensible data': okay_data

.run
    error: false
