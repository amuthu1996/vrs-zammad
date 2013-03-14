class App.Interval
  _instance = undefined

  @set: ( callback, timeout, key, level ) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.set( callback, timeout, key, level )

  @clear: ( key ) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.clear( key )

  @clearLevel: ( level ) ->
    if _instance == undefined
      _instance ?= new _Singleton
    _instance.clearLevel( level )

class _Singleton extends Spine.Module
  @include App.Log

  constructor: ->
    @levelStack = {}

  set: ( callback, timeout, key, level ) ->

    if !level
      level = '_all'

    if !@levelStack[level]
      @levelStack[level] = {}

    if key
      @clear( key )

    if !key
      key = Math.floor( Math.random() * 99999 )

    # setTimeout
    @log 'Interval', 'debug', 'set', key, timeout, level, callback
    callback()
    interval_id = setInterval( callback, timeout )

    # remember all interval
    @levelStack[ level ][ key.toString() ] = {
      interval_id: interval_id
      timeout:     timeout
      level:       level
    }

    return interval_id

  clear: ( key, level ) ->

    if !level
      level = '_all'

    if !@levelStack[ level ]
      @levelStack[ level ] = {}

    # get global interval ids
    data = @levelStack[ level ][ key.toString() ]
    return if !data

    @log 'Interval', 'debug', 'clear', data
    clearInterval( data['interval_id'] )

  clearLevel: (level) ->
    return if !@levelStack[ level ]
    for key, data of @levelStack[ level ]
      @clear( key, level )
    @levelStack[level] = {}
