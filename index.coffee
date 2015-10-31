cheerio = require 'cheerio'
request = require 'request'
Q =       require 'q'

module.exports.debug = false

# A builder for a chain of extraction methods

class Graze

    constructor: ->
        @chain = []

    execute: ($el) ->
        for call in @chain
            $el = call.func.apply $el, call.args
        return $el


# Construct magic methods

for name, func of cheerio.prototype

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

# A small utility method to extend one object into another

extend = (a, b) ->
    for key, value of b
        a[key] = value

# Navigate a template given a jQuery DOM

traverse = (template, $el, $) ->

    context = this
    result = {}

    for key, val of template

        if val instanceof Graze
            result[key] = val.execute $el

        else if val instanceof Array
            result[key] = []
            $el.each (index) ->
                result[key].push traverse.call( context, val[0], $(this), $ )

        else if val instanceof Function
            result[key] = val.call context, $el, $

        else if typeof val == 'object'
            if module.exports.debug
                console.error "Graze debug: #{ $el.find(key).length } elements matched #{key}"
            extend result, traverse.call( context, val, $el.find(key), $ )

        else if typeof val == 'string'
            result[key] = val

    return result


# Allow the user to nest templates within one another

module.exports.nest = (template) ->
    ($el, $) -> return traverse template, $el, $


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

            deferred.resolve @process body, response

        return deferred.promise

    process: (html, context) ->
        $ = cheerio.load html
        traverse.call context, @template, $.root(), $

module.exports.template = (template) ->
    return new Template template


# Private methods for testing purposes

module.exports._patch_request = (request_patch, func) ->
    request = request_patch
    func()
    request = require 'request'
