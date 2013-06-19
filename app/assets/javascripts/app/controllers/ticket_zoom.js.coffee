class App.TicketZoom extends App.Controller
  constructor: (params) ->
    super
#    console.log 'zoom', params

    # check authentication
    return if !@authenticate()

    @navupdate '#'

    @edit_form      = undefined
    @ticket_id      = params.ticket_id
    @article_id     = params.article_id
    @signature      = undefined
    @doNotLog       = params['doNotLog'] || 0

    @key = 'ticket::' + @ticket_id
    cache = App.Store.get( @key )
    if cache
      @load(cache)
    update = =>
      @fetch( @ticket_id, false )
    @interval( update, 120000, @key, 'ticket_zoom' )

    # fetch new data if triggered
    App.Event.bind(
      'ticket:updated'
      (data) =>
        update = =>
          if data.id.toString() is @ticket_id.toString()
            ticket = App.Collection.find( 'Ticket', @ticket_id )
            console.log('TRY', data.updated_at, ticket.updated_at)
            if data.updated_at isnt ticket.updated_at
              @fetch( @ticket_id, false )
        @delay( update, 2000, 'ticket-zoom-' + @ticket_id )
      'ticket-zoom-' + @ticket_id
    )

  meta: =>
    return if !@ticket
    ticket = App.Collection.find( 'Ticket', @ticket.id )
    meta =
      url:   @url()
      head:  ticket.title
      title: '#' + ticket.number + ' - ' + ticket.title
      id:    ticket.id

  url: =>
    '#ticket/zoom/' + @ticket.id

  activate: =>
    @navupdate '#'

  changed: =>
    formCurrent = @formParam( @el.find('.ticket-update') )
    diff = difference( @formDefault, formCurrent )
    return false if !diff || _.isEmpty( diff )
    return true

  release: =>
    App.Event.unbindLevel 'ticket-zoom-' + @ticket_id
    @clearInterval( @key, 'ticket_zoom' )
    @el.remove()

  autosave: =>
    @auto_save_key = 'zoom' + @id
    update = =>
      data = @formParam( @el.find('.ticket-update') )
      diff = difference( @autosaveLast, data )
      if !@autosaveLast || ( diff && !_.isEmpty( diff ) )
        @autosaveLast = data
        console.log('form hash changed', diff, data)
        App.TaskManager.update( @task_key, { 'state': data })
    @interval( update, 10000, @id,  @auto_save_key )

  fetch: (ticket_id, force) ->

    return if !@Session.all()

    # get data
    App.Com.ajax(
      id:    'ticket_zoom_' + ticket_id
      type:  'GET'
      url:   'api/ticket_full/' + ticket_id + '?do_not_log=' + @doNotLog
      data:
        view: @view
      processData: true
      success: (data, status, xhr) =>
        if @dataLastCall && !force

          # return if ticket hasnt changed
          return if _.isEqual( @dataLastCall.ticket, data.ticket )

          # trigger task notify
          diff = difference( @dataLastCall.ticket, data.ticket )
          console.log('diff', diff)

          # notify if ticket changed not by my self
          if !_.isEmpty(diff) && data.ticket.updated_by_id isnt @Session.all().id
            App.TaskManager.notify( @task_key )

        # remember current data
        @dataLastCall = data

        @load(data, force)
        App.Store.write( @key, data )

        # start auto save
        @autosave()

      error: (xhr, status, error) =>

        # do not close window if request is aborted
        return if status is 'abort'

        # do not close window on network error but if object is not found
        return if status is 'error' && error isnt 'Not Found'

        # remove task
        App.TaskManager.remove( @task_key )
    )
    @doNotLog = 1

  load: (data, force) =>

    # reset old indexes
    @ticket = undefined

    # get edit form attributes
    @edit_form = data.edit_form

    # get signature
    @signature = data.signature

    # load user collection
    App.Collection.load( type: 'User', data: data.users )

    # load ticket collection
    App.Collection.load( type: 'Ticket', data: [data.ticket] )

    # load article collections
    App.Collection.load( type: 'TicketArticle', data: data.articles )

    # render page
    @render(force)

  render: (force) =>

    # get data
    @ticket = App.Collection.find( 'Ticket', @ticket_id )

    # update taskbar with new meta data
    App.Event.trigger 'task:render'

    if !@renderDone
      @renderDone = true
      @html App.view('ticket_zoom')(
        ticket:     @ticket
        nav:        @nav
        isCustomer: @isRole('Customer')
      )

    # show frontend times
    @frontendTimeUpdate()

    @TicketTitle()
    @TicketInfo()
    @TicketAction()
    @ArticleView()

    if force || !@editDone
      @editDone = true
      @Edit()

    # show text module UI
    if !@isRole('Customer')
      new App.TextModuleUI(
        el:   @el
        data:
          ticket: @ticket
      )

    # scroll to article if given
    if @article_id && document.getElementById( 'article-' + @article_id )
      offset = document.getElementById( 'article-' + @article_id ).offsetTop
      offset = offset - 45
      scrollTo = ->
        @scrollTo( 0, offset )
      @delay( scrollTo, 100, undefined, 'page' )

  TicketTitle: =>
    # show ticket title
    new TicketTitle(
      ticket:   @ticket
      el:       @el.find('.ticket-title')
    )

  TicketInfo: =>
    # show ticket info
    new TicketInfo(
      ticket:   @ticket
      el:       @el.find('.ticket-info')
    )

  ArticleView: =>
    # show article
    new ArticleView(
      ticket:   @ticket
      el:       @el.find('.article-view')
      ui:       @
    )

  Edit: =>
    # show edit
    new Edit(
      ticket:     @ticket
      el:         @el.find('.edit')
      form_state: @form_state
      edit_form:  @edit_form
      task_key:   @task_key
      ui:         @
    )

  TicketAction: =>
    # show ticket action row
    new TicketAction(
      ticket:     @ticket
      el:         @el.find('.ticket-action')
      ui:         @
    )

class TicketTitle extends App.Controller
  events:
    'blur .ticket-title-update': 'update'

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('ticket_zoom/ticket_title')(
      ticket: @ticket
    )

  update: (e) =>
    $this = $(e.target)
    title = $this.html()
    title = ('' + title)
      .replace(/<.+?>/g, '')
    title = ('' + title)
      .replace(/&nbsp;/g, ' ')
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
    if title is '-'
      title = ''

    # update title
    ticket = App.Collection.find( 'Ticket', @ticket.id )
    ticket.title = title
    ticket.load( title: title )
    ticket.save()

    # update taskbar with new meta data
    App.Event.trigger 'task:render'


class TicketInfo extends App.Controller
  constructor: ->
    super
    @render()

  render: ->
    @html App.view('ticket_zoom/ticket_info')(
      ticket: @ticket
    )

class TicketAction extends App.Controller
  constructor: ->
    super
    @render()

  render: ->

    @html App.view('ticket_zoom/ticket_action')()

    # start customer info controller
    if !@isRole('Customer')
      new App.UserInfo(
        el:      @el.find('.customer_info')
        user_id: @ticket.customer_id
        ticket:  @ticket
      )

    # start action controller
    if !@isRole('Customer')
      new TicketActionRow(
        el:      @el.find('.action_info')
        ticket:  @ticket
        zoom:    @ui
      )

    # start tag controller
    if !@isRole('Customer')
      new App.TagWidget(
        el:           @el.find('.tag_info')
        object_type:  'Ticket'
        object:        @ticket
      )

    # start link info controller
    if !@isRole('Customer')
      new App.LinkInfo(
        el:           @el.find('.link_info')
        object_type:  'Ticket'
        object:       @ticket
      )



class Edit extends App.Controller
  events:
    'click .submit': 'update'

  constructor: ->
    super
    @render()

  render: ->

    ticket = App.Collection.find( 'Ticket', @ticket.id )

    @html App.view('ticket_zoom/edit')(
      ticket:     ticket
      isCustomer: @isRole('Customer')
    )

    @configure_attributes_ticket = [
      { name: 'ticket_state_id',    display: 'State',    tag: 'select',   multiple: false, null: true, relation: 'TicketState', filter: @edit_form, translate: true, class: 'span2', item_class: 'pull-left' },
      { name: 'ticket_priority_id', display: 'Priority', tag: 'select',   multiple: false, null: true, relation: 'TicketPriority', filter: @edit_form, translate: true, class: 'span2', item_class: 'pull-left' },
      { name: 'group_id',           display: 'Group',    tag: 'select',   multiple: false, null: true, relation: 'Group', filter: @edit_form, class: 'span2', item_class: 'pull-left'  },
      { name: 'owner_id',           display: 'Owner',    tag: 'select',   multiple: false, null: true, relation: 'User', filter: @edit_form, nulloption: true, class: 'span2', item_class: 'pull-left' },
    ]
    if @isRole('Customer')
      @configure_attributes_ticket = [
        { name: 'ticket_state_id',    display: 'State',    tag: 'select',   multiple: false, null: true, relation: 'TicketState', filter: @edit_form, translate: true, class: 'span2', item_class: 'pull-left' },
        { name: 'ticket_priority_id', display: 'Priority', tag: 'select',   multiple: false, null: true, relation: 'TicketPriority', filter: @edit_form, translate: true, class: 'span2', item_class: 'pull-left' },
      ]

    @configure_attributes_article = [
      { name: 'ticket_article_type_id',   display: 'Type',        tag: 'select',   multiple: false, null: true, relation: 'TicketArticleType', filter: @edit_form, default: '9', translate: true, class: 'medium' },
      { name: 'to',                       display: 'To',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', hide: true },
      { name: 'cc',                       display: 'Cc',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', hide: true },
#      { name: 'subject',                  display: 'Subject',     tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', hide: true },
      { name: 'in_reply_to',              display: 'In Reply to', tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
      { name: 'body',                     display: 'Text',        tag: 'textarea', rows: 6,  limit: 100, null: true, class: 'span7', item_class: '', upload: true },
      { name: 'internal',                 display: 'Visability',  tag: 'select',   null: true, options: { true: 'internal', false: 'public' }, class: 'medium', item_class: '', default: false },
    ]
    if @isRole('Customer')
      @configure_attributes_article = [
        { name: 'to',           display: 'To',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', hide: true },
        { name: 'cc',           display: 'Cc',          tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', hide: true },
#        { name: 'subject',     display: 'Subject',     tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', hide: true },
        { name: 'in_reply_to',  display: 'In Reply to', tag: 'input',    type: 'text', limit: 100, null: true, class: 'span7', item_class: 'hide' },
        { name: 'body',         display: 'Text',        tag: 'textarea', rows: 6,  limit: 100, null: true, class: 'span7', item_class: '', upload: true },
      ]

    @form_id = App.ControllerForm.formId()
    defaults = @form_state || ticket
    new App.ControllerForm(
      el:        @el.find('.form-ticket-update')
      form_id:   @form_id
      model:
        configure_attributes: @configure_attributes_ticket
        className:            'update_ticket_' + ticket.id
      params:    defaults
      form_data: @edit_form
    )

    new App.ControllerForm(
      el:        @el.find('.form-article-update')
      form_id:   @form_id
      model:
        configure_attributes: @configure_attributes_article
        className:            'update_ticket_' + ticket.id
      form_data: @edit_form
      params:    defaults
      dependency: [
        {
          bind: {
            name:     'ticket_article_type_id'
            relation: 'TicketArticleType'
            value:    ["email"]
          },
          change: {
            action: 'show'
            name: ['to', 'cc'],
          },
        },
        {
          bind: {
            name:     'ticket_article_type_id'
            relation: 'TicketArticleType'
            value:    ['note', 'twitter status', 'twitter direct-message']
          },
          change: {
            action: 'hide'
            name: ['to', 'cc'],
          },
        },
      ]
    )

    @el.find('textarea').elastic()

    # remember form defaults
    @formDefault = @formParam( @el.find('.ticket-update') )

    # enable user popups
    @userPopups()

  update: (e) =>
    e.preventDefault()
    params = @formParam(e.target)

    ticket = App.Collection.find( 'Ticket', @ticket.id )

    @log 'TicketZoom', 'notice', 'update', params, ticket
    article_type = App.Collection.find( 'TicketArticleType', params['ticket_article_type_id'] )

    # update ticket
    ticket_update = {}
    for item in @configure_attributes_ticket
      ticket_update[item.name] = params[item.name]

    # check owner assignment
    if !@isRole('Customer')
      if !ticket_update['owner_id']
        ticket_update['owner_id'] = 1

    # check if title exists
    if !ticket_update['title'] && !ticket.title
      alert( App.i18n.translateContent('Title needed') )
      return

    if article_type.name is 'email'

      # check if recipient exists
      if !params['to'] && !params['cc']
        alert( App.i18n.translateContent('Need recipient in "To" or "Cc".') )
        return

      # check if message exists
      if !params['body']
        alert( App.i18n.translateContent('Text needed') )
        return

    # check attachment
    if params['body']
      attachmentTranslated = App.i18n.translateContent('Attachment')
      attachmentTranslatedRegExp = new RegExp( attachmentTranslated, 'i' )
      if params['body'].match(/attachment/i) || params['body'].match( attachmentTranslatedRegExp )
        return if !confirm( App.i18n.translateContent('You use attachment in text but no attachment is attached. Do you want to continue?') )

    ticket.load( ticket_update )
    @log 'TicketZoom', 'notice', 'update ticket', ticket_update, ticket

    # disable form
    @formDisable(e)

    errors = ticket.validate()
    if errors
      @log 'TicketZoom', 'error', 'update', errors
      @formEnable(e)

    ticket.save(
      success: (r) =>

        # create article
        if params['body']
          article = new App.TicketArticle
          params.from      = @Session.get( 'firstname' ) + ' ' + @Session.get( 'lastname' )
          params.ticket_id = ticket.id
          params.form_id   = @form_id

          if !params['internal']
            params['internal'] = false

          # find sender_id
          if @isRole('Customer')
            sender = App.Collection.findByAttribute( 'TicketArticleSender', 'name', 'Customer' )
            type   = App.Collection.findByAttribute( 'TicketArticleType', 'name', 'web' )
            params['ticket_article_type_id'] = type.id
          else
            sender = App.Collection.findByAttribute( 'TicketArticleSender', 'name', 'Agent' )
          params.ticket_article_sender_id = sender.id
          @log 'TicketZoom', 'notice', 'update article', params, sender
          article.load(params)
          errors = article.validate()
          if errors
            @log 'TicketZoom', 'error', 'update article', errors
          article.save(
            success: (r) =>
              @ui.fetch( ticket.id, true )
            error: (r) =>
              @log 'TicketZoom', 'error', 'update article', r
          )
        else
          @ui.fetch( ticket.id, true )

        # reset form after save
        App.TaskManager.update( @task_key, { 'state': undefined })
        @ui.form_state     = undefined
    )

#    errors = article.validate()
#    @log 'error new', errors
#    @formValidate( form: e.target, errors: errors )
    return false


class ArticleView extends App.Controller
  events:
    'click [data-type=public]':     'public_internal'
    'click [data-type=internal]':   'public_internal'
    'click .show_toogle':           'show_toogle'
    'click [data-type=reply]':      'reply'
#    'click [data-type=reply-all]':  'replyall'

  constructor: ->
    super
    @render()

  render: ->

    # get all articles
    @articles = []
    for article_id in @ticket.article_ids
      article = App.Collection.find( 'TicketArticle', article_id )
      @articles.push article

    # rework articles
    for article in @articles
      new Article( article: article )

    @html App.view('ticket_zoom/article_view')(
      ticket:     @ticket
      articles:   @articles
      isCustomer: @isRole('Customer')
    )

    # show frontend times
    @frontendTimeUpdate()

    # enable user popups
    @userPopups()

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

  show_toogle: (e) ->
    e.preventDefault()
    $(e.target).hide()
    if $(e.target).next('div')[0]
      $(e.target).next('div').show()
    else
      $(e.target).parent().next('div').show()

  checkIfSignatureIsNeeded: (article_type) =>

      # add signature
      if @ui.signature && @ui.signature.body && article_type.name is 'email'
        body   = @ui.el.find('[name="body"]').val() || ''
        regexp = new RegExp( escapeRegExp( @ui.signature.body ) , 'i')
        if !body.match(regexp)
          body = body + "\n" + @ui.signature.body
          @ui.el.find('[name="body"]').val( body )

          # update textarea size
          @ui.el.find('[name="body"]').trigger('change')

  reply: (e) =>
    e.preventDefault()
    article_id   = $(e.target).parents('[data-id]').data('id')
    article      = App.Collection.find( 'TicketArticle', article_id )
    article_type = App.Collection.find( 'TicketArticleType', article.ticket_article_type_id )
    customer     = App.Collection.find( 'User', article.created_by_id )

    # update form
    @checkIfSignatureIsNeeded(article_type)

    # preselect article type
    @ui.el.find('[name="ticket_article_type_id"]').find('option:selected').removeAttr('selected')
    @ui.el.find('[name="ticket_article_type_id"]').find('[value="' + article_type.id + '"]').attr('selected',true)
    @ui.el.find('[name="ticket_article_type_id"]').trigger('change')

    # empty form
    #@ui.el.find('[name="to"]').val('')
    #@ui.el.find('[name="cc"]').val('')
    #@ui.el.find('[name="subject"]').val('')
    @ui.el.find('[name="in_reply_to"]').val('')

    if article.message_id
      @ui.el.find('[name="in_reply_to"]').val(article.message_id)

    if article_type.name is 'twitter status'

      # set to in body
      to = customer.accounts['twitter'].username || customer.accounts['twitter'].uid
      @ui.el.find('[name="body"]').val('@' + to)

    else if article_type.name is 'twitter direct-message'

      # show to
      to = customer.accounts['twitter'].username || customer.accounts['twitter'].uid
      @ui.el.find('[name="to"]').val(to)

    else if article_type.name is 'email'
      @ui.el.find('[name="to"]').val(article.from)
#    @log 'reply ', article, @el.find('[name="to"]')

    # add quoted text if needed
    selectedText = App.ClipBoard.getSelected()
    if selectedText
      body = @ui.el.find('[name="body"]').val() || ''
      selectedText = selectedText.replace /^(.*)$/mg, (match) =>
        '> ' + match
      body = selectedText + "\n" + body
      @ui.el.find('[name="body"]').val(body)

      # update textarea size
      @ui.el.find('[name="body"]').trigger('change')

class Article extends App.Controller
  constructor: ->
    super

    # define actions
    @actionRow()

    # check attachments
    @attachments()

    # html rework
    @preview()

  preview: ->

    # build html body
    # cleanup body
#    @article['html'] = @article.body.trim()
    @article['html'] = $.trim( @article.body )
    @article['html'].replace( /\n\r/g, "\n" )
    @article['html'].replace( /\n\n\n/g, "\n\n" )

    # if body has more then x lines / else search for signature
    preview       = 10
    preview_mode  = false
    article_lines = @article['html'].split(/\n/)
    if article_lines.length > preview
      preview_mode = true
      if article_lines[preview] is ''
        article_lines.splice( preview, 0, '----SEEMORE----' )
      else
        article_lines.splice( preview + 1, 0, '----SEEMORE----' )
      @article['html'] = article_lines.join("\n")
    @article['html'] = window.linkify( @article['html'] )
    notify = '<a href="#" class="show_toogle">' + App.i18n.translateContent('See more') + '</a>'

    # preview mode
    if preview_mode
      @article_changed = false
      @article['html'] = @article['html'].replace /^\n{0,10}----SEEMORE----\n/m, (match) =>
        @article_changed = true
        notify + '<div class="hide">'
      if @article_changed
        @article['html'] = @article['html'] + '</div>'

    # hide signatures and so on
    else
      @article_changed = false
      @article['html'] = @article['html'].replace /^\n{0,10}(--|__)/m, (match) =>
        @article_changed = true
        notify + '<div class="hide">' + match
      if @article_changed
        @article['html'] = @article['html'] + '</div>'


  actionRow: ->
    if @isRole('Customer')
      @article.actions = []
      return

    actions = []
    if @article.internal is true
      actions = [
        {
          name: 'set to public'
          type: 'public'
        }
      ]
    else
      actions = [
        {
          name: 'set to internal'
          type: 'internal'
        }
      ]
    if @article.article_type.name is 'note'
#        actions.push []
    else
      if @article.article_sender.name is 'Customer'
        actions.push {
          name: 'reply'
          type: 'reply'
          href: '#'
        }
#        actions.push {
#          name: 'reply all'
#          type: 'reply-all'
#          href: '#'
#        }
        actions.push {
          name: 'split'
          type: 'split'
          href: '#ticket_create/' + @article.ticket_id + '/' + @article.id
        }
    @article.actions = actions

  attachments: ->
    if @article.attachments
      for attachment in @article.attachments
        attachment.size = @humanFileSize(attachment.size)

class TicketActionRow extends App.Controller
  events:
    'click [data-type=history]':  'history_dialog'
    'click [data-type=merge]':    'merge_dialog'
    'click [data-type=customer]': 'customer_dialog'

  constructor: ->
    super
    @render()

  render: ->
    @html App.view('ticket_action')()

  history_dialog: (e) ->
    e.preventDefault()
    new App.TicketHistory( ticket_id: @ticket.id )

  merge_dialog: (e) ->
    e.preventDefault()
    new App.TicketMerge( ticket_id: @ticket.id, task_key: @zoom.task_key )

  customer_dialog: (e) ->
    e.preventDefault()
    new App.TicketCustomer( ticket_id: @ticket.id, zoom: @zoom )

class TicketZoomRouter extends App.ControllerPermanent
  constructor: (params) ->
    super
    @log 'zoom router', params

    # cleanup params
    clean_params =
      ticket_id:  params.ticket_id
      article_id: params.article_id
      nav:        params.nav

    App.TaskManager.add( 'Ticket-' + @ticket_id, 'TicketZoom', clean_params )

App.Config.set( 'ticket/zoom/:ticket_id', TicketZoomRouter, 'Routes' )
App.Config.set( 'ticket/zoom/:ticket_id/nav/:nav', TicketZoomRouter, 'Routes' )
App.Config.set( 'ticket/zoom/:ticket_id/:article_id', TicketZoomRouter, 'Routes' )