class Observer::Ticket::ResetNewState < ActiveRecord::Observer
  observe 'ticket::_article'

  def after_create(record)
#    puts 'check reset new state'

    # return if we run import mode
    return if Setting.get('import_mode')

    # if article in internal
    return true if record.internal

    # if sender is agent
    return true if Ticket::Article::Sender.lookup( :id => record.ticket_article_sender_id ).name != 'Agent'

    # if article is a message to customer
    return true if !Ticket::Article::Type.lookup( :id => record.ticket_article_type_id ).communication

    # if current ticket state is still new
    ticket = Ticket.lookup( :id => record.ticket_id )
    return true if ticket.ticket_state.state_type.name != 'new'

    # TODO: add config option to state managment in UI
    state = Ticket::State.lookup( :name => 'open' )
    return if !state

    # set ticket to open
    ticket.ticket_state_id = state.id

    # save ticket
    ticket.save
  end
end