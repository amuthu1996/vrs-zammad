$ = jQuery.sub()

class App.WebSocket
  _instance = undefined # Must be declared here to force the closure on the class
  @connect: (args) -> # Must be a static method
    if _instance == undefined
      _instance ?= new _Singleton
    _instance

  @send: (args) -> # Must be a static method
    @connect()
    _instance.send(args)

  @auth: (args) -> # Must be a static method
    @connect()
    _instance.auth(args)

# The actual Singleton class
class _Singleton extends Spine.Controller
  queue: []

  constructor: (@args) ->
    @connect()

  send: (data) =>
    console.log 'ws:send trying', data, @ws, @ws.readyState

    # A value of 0 indicates that the connection has not yet been established.
    # A value of 1 indicates that the connection is established and communication is possible.
    # A value of 2 indicates that the connection is going through the closing handshake.
    # A value of 3 indicates that the connection has been closed or could not be opened.
    if @ws.readyState is 0
      @queue.push data
    else
      console.log( 'ws:send', data )
      string = JSON.stringify( data )
      @ws.send(string)

  auth: (data) =>

    # logon websocket
    data = {
      action: 'login',
      session: window.Session
    }
    @send(data)

  close: =>
    @ws.close()

  connect: =>
#    console.log '------------ws connect....--------------'

    if !window.WebSocket
      @error = new App.ErrorModal(
        message: 'Sorry, no websocket support!'
      )
      return

    @ws = new window.WebSocket( "ws://" + window.location.hostname + ":6042/" )

    # Set event handlers.
    @ws.onopen = =>
      console.log( "onopen" )

      # close error message if exists
      if @error
        @error.modalHide()
        @error = undefined

      @auth()

      # empty queue
      for item in @queue
        console.log( 'ws:send queue', item )
        @send(item)
      @queue = []

    @ws.onmessage = (e) ->
      pipe = JSON.parse( e.data )
#      console.log( "ws:onmessage", pipe )

      # go through all blocks
      for item in pipe

        # fill collection
        if item['collection']
          console.log( "ws:onmessage collection:" + item['collection'] )
          window.LastRefresh[ item['collection'] ] = item['data']

        # fire event
        if item['event']
          console.log( "ws:onmessage event:" + item['event'] )
          Spine.trigger( item['event'], item['data'] )

    # bind to send messages
    Spine.bind 'ws:send', (data) =>
      @send(data)

    @ws.onclose = (e) =>
      console.log( "onclose", e )

      # show error message
      if !@error
        @error = new App.ErrorModal(
          message: 'No connection to websocket, trying to reconnect...'
        )

      # try reconnect after 5 sec.
      @delay @connect, 5000

    @ws.onerror = ->
      console.log( "onerror" )
