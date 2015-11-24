class App.TicketCustomer extends App.ControllerModalNice
  buttonClose: true
  buttonCancel: true
  buttonSubmit: true
  head: 'Change Customer'

  content: ->
    configure_attributes = [
      { name: 'customer_id', display: 'Customer', tag: 'user_autocompletion', null: false, placeholder: 'Enter Person or Organization/Company', minLengt: 2, disableCreateUser: true },
    ]
    controller = new App.ControllerForm(
      model:
        configure_attributes: configure_attributes,
      autofocus: true
    )
    controller.form

  onSubmit: (e) =>
    params = @formParam(e.target)

    @customer_id = params['customer_id']

    callback = =>

      # close modal
      @close()

      # update ticket
      @ticket.updateAttributes(
        customer_id: @customer_id
      )

    # load user if not already exists
    App.User.full( @customer_id, callback )