class Observer::Ticket::Article::FillupFromGeneral < ActiveRecord::Observer
  observe 'ticket::_article'

  def before_create(record)

    # return if we run import mode
    return if Setting.get('import_mode')

    # if sender is customer, do not change anything
    sender = Ticket::Article::Sender.where( :id => record.ticket_article_sender_id ).first
    return if sender == nil
    return if sender['name'] == 'Customer'

    # set from if not given
    if !record.from
      user = User.find( record.created_by_id )
      record.from = "#{user.firstname} #{user.lastname}"
    end
  end
end