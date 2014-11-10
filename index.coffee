jsdom =   require('jsdom').jsdom
$ =       require('jquery')(jsdom().parentWindow)
request = require 'request'
Q =       require 'q'


# A builder for a chain of extraction methods

class Graze

    constructor: ->
        @chain = []

    execute: ($el) ->
        for call in @chain
            $el = call.func.apply $el, call.args
        return $el


# Construct magic methods

for name, func of $.fn

    do (name, func) ->

        Graze.prototype[name] = ->
            @chain.push
                func: func
                args: arguments
            return this

        module.exports[name] = ->
            graze = new Graze()
            graze[name](arguments...)
            return graze


# Navigate a template given a jQuery DOM

traverse = (template, $el) ->

    result = {}

    for key, val of template

        if val instanceof Graze
            result[key] = val.execute $el

        else if val instanceof Array
            result[key] = []
            $el.each (index) ->
                result[key].push traverse val[0], $ this

        else if val instanceof Function
            result[key] = val $el

        else if typeof val == 'object'
            $.extend result, traverse val, $el.find key

    return result


# Stores a template and allows for scraping on a given URL

class Template

    constructor: (@template) ->

    scrape: (options) ->
        
        if typeof options == 'string'
          options = uri: options

        deferred = Q.defer()
        options.header ?= 'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like
Gecko) Chrome/31.0.1650.63 Safari/537.36'

        request options, (error, response, body) =>

            if error or response.statusCode != 200
                return deferred.reject {error, response, body}

            deferred.resolve @process body

        return deferred.promise

    process: (html) =>

        traverse @template, $ html

module.exports.template = (template) ->
    return new Template template
