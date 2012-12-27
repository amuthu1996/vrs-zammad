class Observer::Ticket::Article::FillupFromEmail < ActiveRecord::Observer
  observe 'ticket::_article'

  def before_create(record)

    # return if we run import mode
    return if Setting.get('import_mode')

    # if sender is customer, do not change anything
    sender = Ticket::Article::Sender.where( :id => record.ticket_article_sender_id ).first
    return if sender == nil
    return if sender['name'] == 'Customer'

    # set email attributes
    type = Ticket::Article::Type.where( :id => record.ticket_article_type_id ).first
    return if type['name'] != 'email'

    # set subject if empty
    ticket = Ticket.find( record.ticket_id )
    if !record.subject || record.subject == ''
      record.subject = ticket.title
    end

    # clean subject
    record.subject = ticket.subject_clean( record.subject )

    # generate message id
    fqdn = Setting.get('fqdn')
    record.message_id = '<' + DateTime.current.to_s(:number) + '.' + record.ticket_id.to_s + '.' + rand(999999).to_s() + '@' + fqdn + '>'

    # set sender
    email_address = ticket.group.email_address
    system_sender = "#{email_address.realname} <#{email_address.email}>"
    if Setting.get('ticket_define_email_from') == 'AgentNameSystemAddressName'
      seperator = Setting.get('ticket_define_email_from_seperator')
      sender    = User.find( record.created_by_id )
      record.from = "#{sender.firstname} #{sender.lastname} #{seperator} #{system_sender}"
    else
      record.from = system_sender
    end
  end
end