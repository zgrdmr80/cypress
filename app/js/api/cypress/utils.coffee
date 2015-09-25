$Cypress.Utils = do ($Cypress, _) ->

  tagOpen     = /\[([a-z\s='"-]+)\]/g
  tagClosed   = /\[\/([a-z]+)\]/g
  quotesRe    = /('|")/g

  CYPRESS_OBJECT_NAMESPACE = "_cypressObj"

  return {
    normalizeObjWithLength: (obj) ->
      ## underscore shits the bed if our object has a 'length'
      ## property so we have to normalize that
      if _(obj).has("length")
        obj.Length = obj.length
        delete obj.length

      obj

    ## return a new object if the obj
    ## contains the properties of filter
    ## and the values are different
    filterDelta: (obj, filter) ->
      filter = @normalizeObjWithLength(filter)

      obj = _.reduce filter, (memo, value, key) ->
        key = key.toLowerCase()

        if _(obj).has(key) and obj[key] isnt value
          memo[key] = obj[key]

        memo
      , {}

      if _.isEmpty(obj) then undefined else obj

    _stringifyObj: (obj) ->
      obj = @normalizeObjWithLength(obj)

      str = _.reduce obj, (memo, value, key) =>
        memo.push key.toLowerCase() + ": " + @_stringify(value)
        memo
      , []

      "{" + str.join(", ") + "}"

    _stringify: (value) ->
      switch
        when @hasElement(value)
          @stringifyElement(value, "short")

        when _.isFunction(value)
          "function(){}"

        when _.isArray(value)
          len = value.length
          if len > 3
            "Array[#{len}]"
          else
            "[" + _.map(value, _.bind(@_stringify, @)).join(", ") + "]"

        when _.isRegExp(value)
          value.toString()

        when _.isObject(value)
          len = _.keys(value).length
          if len > 2
            "Object{#{len}}"
          else
            @_stringifyObj(value)

        when _.isUndefined(value)
          undefined

        else
          "" + value

    stringify: (values) ->
      ## if we already have an array
      ## then nest it again so that
      ## its formatted properly
      values = [].concat(values)

      _.chain(values)
        .map(_.bind(@_stringify, @))
          .without(undefined)
            .value()
              .join(", ")

    hasWindow: (obj) ->
      try
        !!(obj and $.isWindow(obj[0])) or $.isWindow(obj)
      catch
        false

    hasElement: (obj) ->
      try
        !!(obj and obj[0] and _.isElement(obj[0])) or _.isElement(obj)
      catch
        false

    hasDocument: (obj) ->
      try
        !!((obj and obj.nodeType is 9) or (obj and obj[0] and obj[0].nodeType is 9))
      catch
        false

    isDescendent: ($el1, $el2) ->
      return false if not $el2

      !!(($el1.get(0) is $el2.get(0)) or $el1.has($el2).length)

    getDomElements: ($el) ->
      return if not $el?.length

      if $el.length is 1
        $el.get(0)
      else
        _.reduce $el, (memo, el) ->
          memo.push(el)
          memo
        , []

    ## short form css-inlines the element
    ## long form returns the outerHTML
    stringifyElement: (el, form = "long") ->
      el = if _.isElement(el) then $(el) else el

      switch form
        when "long"
          el.clone().empty().prop("outerHTML")
        when "short"
          str = el.prop("tagName").toLowerCase()
          if id = el.prop("id")
            str += "#" + id

          if klass = el.prop("class")
            str += "." + klass.split(/\s+/).join(".")

          "<#{str}>"

    plural: (obj, plural, singular) ->
      obj = if _.isNumber(obj) then obj else obj.length
      if obj > 1 then plural else singular

    convertHtmlTags: (html) ->
      html
        .replace(tagOpen, "<$1>")
        .replace(tagClosed, "</$1>")

    isInstanceOf: (instance, constructor) ->
      try
        instance instanceof constructor
      catch e
        false

    escapeQuotes: (text) ->
      ## convert to str and escape any single
      ## or double quotes
      ("" + text).replace(quotesRe, "\\$1")

    getCypressNamespace: (obj) ->
      obj and obj[CYPRESS_OBJECT_NAMESPACE]

    ## backs up an original object to another
    ## by going through the cypress object namespace
    setCypressNamespace: (obj, original) ->
      obj[CYPRESS_OBJECT_NAMESPACE] = original
  }