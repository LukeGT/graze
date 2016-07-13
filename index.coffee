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

traverse = (value, $el, $) ->

    context = this

    if value instanceof Graze
        return value.execute $el

    else if value instanceof Array
        return (for el in $el
            traverse.call context, value[0], $(el), $
        )

    else if value instanceof Function
        return value.call context, $el, $

    else if typeof value == 'object'
        result = {}
        for key, val of value
            if Object.getPrototypeOf(val) == Object.prototype
                if module.exports.debug
                    console.error "Graze debug: #{ $el.find(key).length } elements matched #{key}"
                extend result, traverse.call( context, val, $el.find(key), $ )
            else
                result[key] = traverse.call( context, val, $el, $ )
        return result

    else
        return value

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
