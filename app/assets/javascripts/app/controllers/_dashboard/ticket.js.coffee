$ = jQuery.sub()

class App.DashboardTicket extends App.Controller
  events:
    'click [data-type=edit]':     'zoom'
    'click [data-type=settings]': 'settings'
    'click [data-type=page]':     'page'

  constructor: ->
    super
    @tickets       = []
    @tickets_count = 0
    @start_page    = 1
    @navupdate '#'

    @fetch()

  fetch: ->

    # get data
    @ajax = new App.Ajax
    @ajax.ajax(
      type:  'GET',
      url:   '/ticket_overviews',
      data:  {
        view:       @view,
        view_mode:  'd',
        start_page: @start_page,
      }
      processData: true,
#      data: JSON.stringify( view: @view ),
      success: (data, status, xhr) =>

        # get meta data
        @overview = data.overview
        App.Overview.refresh( @overview, options: { clear: true } )

        App.Overview.unbind('local:rerender')
        App.Overview.bind 'local:rerender', (record) =>
          @log 'rerender...', record
          @render()

        App.Overview.unbind('local:refetch')
        App.Overview.bind 'local:refetch', (record) =>
          @log 'refetch...', record
          @fetch()

        # load user collection
        @loadCollection( type: 'User', data: data.users )

        # load ticket collection
        @loadCollection( type: 'Ticket', data: data.tickets )

        @tickets       = data.tickets
        @tickets_count = data.tickets_count

        @render()
    )

  render: ->
    
    pages_total =  parseInt( ( @tickets_count / @overview.view.d.per_page ) + 0.99999 ) || 1
    html = App.view('dashboard/ticket')(
      overview:    @overview,
      pages_total: pages_total,
      start_page:  @start_page,
    )
    html = $(html)
    html.find('li').removeClass('active')
    html.find("[data-id=\"#{@start_page}\"]").parents('li').addClass('active')


    shown_all_attributes = @ticketTableAttributes( App.Overview.find(@overview.id).view.d.overview )
    table = @table(
      overview_extended: shown_all_attributes,
      model:             App.Ticket,
      objects:           @tickets,
      checkbox:          false,
    )

    if _.isEmpty(@tickets)
      table = ''
#      table = '-none-'

    # append content table
    html.find('.table-overview').append(table)
    @html html

    # start user popups
    @userPopups()

  zoom: (e) =>
    e.preventDefault()
    id = $(e.target).parents('[data-id]').data('id')
    @log 'goto zoom!'
    @navigate 'ticket/zoom/' + id

  settings: (e) =>
    e.preventDefault()
    new Settings(
      overview: App.Overview.find(@overview.id)
    )

  page: (e) =>
    e.preventDefault()
    id = $(e.target).data('id')
    @start_page = id
    @fetch()

class Settings extends App.ControllerModal
  constructor: ->
    super
    @render()

  render: ->

    @html App.view('dashboard/ticket_settings')(
      overview: @overview,
    )
    @configure_attributes_article = [
#      { name: 'from',                     display: 'From',     tag: 'input',    type: 'text', limit: 100, null: false, class: 'span8',  },
#      { name: 'to',                       display: 'To',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
#      { name: 'ticket_article_type_id',   display: 'Type',        tag: 'select',   multiple: false, null: true, relation: 'TicketArticleType', default: '9', class: 'medium', item_class: 'keepleft' },
#      { name: 'internal',                 display: 'Visability',  tag: 'radio',  default: false,  null: true, options: { true: 'internal', false: 'public' }, class: 'medium', item_class: 'keepleft' },
      {
        name:     'per_page',
        display:  'Items per page',
        tag:      'select',
        multiple: false,
        null:     false,
        default: @overview.view.d.per_page,
        options: {
          5: 5,
          10: 10,
          15: 15,
          20: 20,
        },
        class: 'medium',
#        item_class: 'keepleft',
      },
      { 
        name:    'attributes',
        display: 'Attributes',
        tag:     'checkbox',
        default: @overview.view.d.overview,
        null:    false,
        options: {
          number:                 'Number',
          title:                  'Title',
          customer:               'Customer',
          ticket_state:           'State',
          ticket_priority:        'Priority',
          group:                  'Group',
          owner:                  'Owner',
          created_at:             'Alter',
          last_contact:           'Last Contact',
          last_contact_agent:     'Last Contact Agent',
          last_contact_customer:  'Last Contact Customer',
          first_response:         'First Response',
          close_time:             'Close Time',
        },
        class:      'medium',
#        item_class: 'keepleft',
      },
      { 
        name:    'order_by',
        display: 'Order',
        tag:     'select',
        default: @overview.order.by,
        null:    false,
        options: {
          number:                 'Number',
          title:                  'Title',
          customer:               'Customer',
          ticket_state:           'State',
          ticket_priority:        'Priority',
          group:                  'Group',
          owner:                  'Owner',
          created_at:             'Alter',
          last_contact:           'Last Contact',
          last_contact_agent:     'Last Contact Agent',
          last_contact_customer:  'Last Contact Customer',
          first_response:         'First Response',
          close_time:             'Close Time',
        },
        class:      'medium',
      },
      { 
        name:    'order_by_direction',
        display: 'Direction',
        tag:     'select',
        default: @overview.order.direction,
        null:    false,
        options: {
          ASC:   'up',
          DESC:  'down',
        },
        class:      'medium',
      },
    ]
    form = @formGen( model: { configure_attributes: @configure_attributes_article } )

    @el.find('.setting').append(form)

    @modalShow()

  submit: (e) =>
    e.preventDefault()
    params = @formParam(e.target)
    
    # check if refetch is needed
    @reload_needed = 0
    if @overview.view['d']['per_page'] isnt params['per_page']
      @overview.view['d']['per_page'] = params['per_page']
      @reload_needed = 1

    if @overview.order['by'] isnt params['order_by']
      @overview.order['by'] = params['order_by']
      @reload_needed = 1

    if @overview.order['direction'] isnt params['order_by_direction']
      @overview.order['direction'] = params['order_by_direction']
      @reload_needed = 1

    @overview.view['d']['overview'] = params['attributes']

    @overview.save(
      success: =>
        if @reload_needed
          @overview.trigger('local:refetch')
        else
          @overview.trigger('local:rerender')
    )

    @modalHide()