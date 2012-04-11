$ = jQuery.sub()

class Index extends App.Controller
  events:
    'click .submit':                          'update',
    'click [data-type=reply]':                'reply',
    'click [data-type=reply-all]':            'replyall',
    'click [data-type=public]':               'public_internal',
    'click [data-type=internal]':             'public_internal',
    'click [data-type=history]':              'history_view',
    'change [name="ticket_article_type_id"]': 'form_update',

  constructor: (params) ->
    super
    @log 'zoom', params

    # check authentication
    return if !@authenticate()

    @navupdate '#'

    @edit_form = undefined
#    @render()
    @ticket_id = params.ticket_id
    @fetch(@ticket_id)

  fetch: (ticket_id) ->
    # get data
    @ajax = new App.Ajax
    @ajax.ajax(
      type:  'GET',
      url:   '/ticket_full/' + ticket_id,
      data:  {
        view: @view
      }
      processData: true,
      success: (data, status, xhr) =>
        # reset old indexes
        @ticket = undefined
        @articles = undefined
        
        # get edit form attributes
        @edit_form = data.edit_form

        # load user collection
        @loadCollection( type: 'User', data: data.users )

        # load ticket collection
        @loadCollection( type: 'Ticket', data: [data.ticket] )

        # load article collections
        @loadCollection( type: 'TicketArticle', data: data.articles || [] )

        # render page
        @render()
    )

  render: =>

    if !App.Ticket.exists(@ticket_id)
      return

    # get data
    if !@ticket
      @ticket = App.Ticket.find(@ticket_id)
    if !@articles
      @articles = []
      for article_id in @ticket.article_ids
        @articles.push App.TicketArticle.find(article_id)

    # check attachments
    for article in @articles
      if article.attachments
        for attachment in article.attachments
          attachment.size = @humanFileSize(attachment.size)

    # define actions
    for article in @articles
      actions = []
      if article.internal is true
        actions = [
          {
            name: 'set to public',
            type: 'public',
          }
        ]
      else
        actions = [
          {
            name: 'set to internal',
            type: 'internal',
          }
        ]      
      if article.article_type.name is 'note'
#        actions.push []
      else
        if article.article_sender.name is 'Customer'
          actions.push {
            name: 'reply',
            type: 'reply',
          }
          actions.push {
            name: 'reply all',
            type: 'reply-all',
          }
      article.actions = actions

    # set title
    @title 'Ticket Zoom ' + @ticket.number
    
    @configure_attributes_ticket = [
      { name: 'ticket_state_id',    display: 'State',    tag: 'select',   multiple: false, null: true, relation: 'TicketState', default: 'new', class: 'span2', item_class: 'keepleft' },
      { name: 'ticket_priority_id', display: 'Priority', tag: 'select',   multiple: false, null: true, relation: 'TicketPriority', default: '2 normal', class: 'span2', item_class: 'keepleft' },
      { name: 'group_id',           display: 'Group',    tag: 'select',   multiple: false, null: true, relation: 'Group', class: 'span2', item_class: 'keepleft'  },
      { name: 'owner_id',           display: 'Owner',    tag: 'select',   multiple: false, null: true, relation: 'User', filter: @edit_form, nulloption: true, class: 'span2', item_class: 'keepleft' },
    ]
    form_ticket = @formGen( model: { configure_attributes: @configure_attributes_ticket, className: 'create' }, params: @ticket )
    @configure_attributes_article = [
#      { name: 'from',                     display: 'From',     tag: 'input',    type: 'text', limit: 100, null: false, class: 'span8',  },
      { name: 'to',                       display: 'To',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
      { name: 'cc',                       display: 'Cc',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
      { name: 'subject',                  display: 'Subject',     tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
      { name: 'in_reply_to',              display: 'In Reply to', tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
      { name: 'body',                     display: 'Text',        tag: 'textarea', rows: 5,  limit: 100, null: true, class: 'span7',  },
      { name: 'ticket_article_type_id',   display: 'Type',        tag: 'select',   multiple: false, null: true, relation: 'TicketArticleType', default: '9', class: 'medium', item_class: 'keepleft' },
      { name: 'internal',                 display: 'Visability',  tag: 'radio',  default: false,  null: true, options: { true: 'internal', false: 'public' }, class: 'medium', item_class: 'keepleft' },
#      { name: 'ticket_article_sender_id', display: 'Sender',   tag: 'select',   multiple: false, null: true, relation: 'TicketArticleSender', default: '', class: 'medium' },
    ]
    form_article = @formGen( model: { configure_attributes: @configure_attributes_article } )
      
    @html App.view('agent_ticket_zoom')(
      ticket:       @ticket,
      articles:     @articles,
      form_ticket:  form_ticket,
      form_article: form_article,
    )

    @userPopups()
    
    # start customer info controller
    new App.UserInfo(
      el:      @el.find('#customer_info'),
      user_id: @ticket.customer_id,
      ticket:  @ticket,
    )

    @delay(@u, 200)
    
  u: =>
    uploader = new qq.FileUploader(
      element: document.getElementById('file-uploader'),
      action: 'ticket_attachment_new',
      params: {
        form:    'TicketZoom',
        form_id: @ticket.id,
      },
      debug: false
    )

  history_view: (e) ->
    e.preventDefault()
    new History( ticket_id: @ticket_id )

  public_internal: (e) ->
    e.preventDefault()
    article_id = $(e.target).parents('[data-id]').data('id')
    
    # storage update
    article = App.TicketArticle.find(article_id)
    internal = true
    if article.internal == true
      internal = false
  
    article.updateAttributes(
      internal: internal
    )

    # runtime update
    for article in @articles
      if article_id is article.id
        article['internal'] = internal

    @render()

  form_update: (e) ->
    ticket_article_type_id = $(e.target).find('option:selected').val()
    @log 'eeee', e, ticket_article_type_id
    article_type = App.TicketArticleType.find( ticket_article_type_id )
    @form_update_execute(article_type)

  form_update_execute: (article_type) =>
    if article_type.name is 'twitter status'

      # hide to
      @el.find('[name="to"]').parents('.control-group').addClass('hide')
      @el.find('[name="cc"]').parents('.control-group').addClass('hide')
      @el.find('[name="subject"]').parents('.control-group').addClass('hide')

    else if article_type.name is 'twitter direct-message'

      # show
      @el.find('[name="to"]').parents('.control-group').removeClass('hide')
      @el.find('[name="cc"]').parents('.control-group').addClass('hide')
      @el.find('[name="subject"]').parents('.control-group').addClass('hide')

    else if article_type.name is 'note'

      # hide to
      @el.find('[name="to"]').parents('.control-group').addClass('hide')
      @el.find('[name="cc"]').parents('.control-group').addClass('hide')
      @el.find('[name="subject"]').parents('.control-group').addClass('hide')

    else if article_type.name is 'email'

      # show
      @el.find('[name="to"]').parents('.control-group').removeClass('hide')
      @el.find('[name="cc"]').parents('.control-group').removeClass('hide')
#      @el.find('[name="subject"]').parents('.control-group').removeClass('hide')

  reply: (e) =>
    e.preventDefault()
    article_id = $(e.target).parents('[data-id]').data('id')
    article = App.TicketArticle.find( article_id )
    article_type = App.TicketArticleType.find( article.ticket_article_type_id )
    customer = App.User.find( article.created_by_id )

    @log 'reply', e, article_type

    # update form
    @form_update_execute(article_type)

    # preselect article type
    @el.find('[name="ticket_article_type_id"]').find('option:selected').removeAttr('selected')
    @el.find('[name="ticket_article_type_id"]').find('[value="' + article_type.id + '"]').attr('selected',true)

    # empty form
    @el.find('[name="to"]').val('')
    @el.find('[name="cc"]').val('')
    @el.find('[name="subject"]').val('')
    @el.find('[name="in_reply_to"]').val('')
    
    if article.message_id
      @el.find('[name="in_reply_to"]').val(article.message_id)

    if article_type.name is 'twitter status'

      # set to in body
      to = customer.accounts['twitter'].username || customer.accounts['twitter'].uid
      @log 'c', customer
      @el.find('[name="body"]').val('@' + to)
      
    else if article_type.name is 'twitter direct-message'
    
      # show to
      to = customer.accounts['twitter'].username || customer.accounts['twitter'].uid
      @el.find('[name="to"]').val(to)
    
    else if article_type.name is 'email'
      @el.find('[name="to"]').val(article.from)
#    @log 'reply ', article, @el.find('[name="to"]')

  update: (e) =>
    e.preventDefault()
    params = @formParam(e.target)
    @log 'update', params, @ticket

    # update ticket
    ticket_update = {}
    for item in @configure_attributes_ticket
      ticket_update[item.name] = params[item.name]
      
    # check owner assignment
    if !ticket_update['owner_id']
      ticket_update['owner_id'] = 1

    @ticket.load( ticket_update )
    @log 'update ticket', ticket_update, @ticket
    
    # disable form
    @formDisable(e)

    @ticket.save(
      success: (r) =>

        # create article
        if params['body']
          article = new App.TicketArticle
          params.from = window.Session['firstname'] + ' ' + window.Session['lastname'] 
          params.ticket_id = @ticket.id
          
          # find sender_id
          sender = App.TicketArticleSender.findByAttribute("name", "Agent")
          params.ticket_article_sender_id = sender.id
          @log 'updateAttributes', params, sender, sender.id
          article.load(params)
          article.save(
            success: (r) =>
              @fetch(@ticket.id)
          )
        else
          @fetch(@ticket.id)
    )
    
#    errors = article.validate()
#    @log 'error new', errors
#    @validateForm( form: e.target, errors: errors )
    return false


class History extends App.ControllerModal
  constructor: ->
    super
    @fetch(@ticket_id)

  fetch: (@ticket_id) ->
    # get data
    @ajax = new App.Ajax
    @ajax.ajax(
      type:  'GET',
      url:   '/ticket_history/' + ticket_id,
      data:  {
#        view: @view
      }
#      processData: true,
      success: (data, status, xhr) =>
        # remember ticket
        @ticket = data.ticket

        # load user collection
        @loadCollection( type: 'User', data: data.users )

        # load ticket collection
        @loadCollection( type: 'Ticket', data: [data.ticket] )

        # load history_type collections
        @loadCollection( type: 'HistoryType', data: data.history_types )

        # load history_object collections
        @loadCollection( type: 'HistoryObject', data: data.history_objects )

        # load history_attributes collections
        @loadCollection( type: 'HistoryAttribute', data: data.history_attributes )

        # load history collections
        App.History.deleteAll()
        @loadCollection( type: 'History', data: data.history )

        # render page
        @render()
    )

  render: ->


    # create table/overview
    table = @table(
      overview_extended: [
        { name: 'type', },
        { name: 'attribute', },
        { name: 'value_from', },
        { name: 'value_to', },
        { name: 'created_by', class: 'user-data', data: { id: 1 } },
        { name: 'created_at', callback: @humanTime },
      ],
      model: App.History,
      objects: App.History.all(),
    )


    @html App.view('agent_ticket_history')(
#      head: 'New User',
#      form: @formGen( model: App.User, required: 'quick' ),
    )
    @el.find('.table_history').append(table)

    @modalShow()
    
    @userPopups()

Config.Routes['ticket/zoom/:ticket_id'] = Index
Config.Routes['ticket/zoom/:ticket_id/:article_id'] = Index