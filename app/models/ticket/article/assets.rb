# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

module Ticket::Article::Assets

=begin

get all assets / related models for this article

  article = Ticket::Article.find(123)
  result = article.assets( assets_if_exists )

returns

  result = {
    :users => {
      123  => user_model_123,
      1234 => user_model_1234,
    }
    :article => [ article_model1 ],
  }

=end

  def assets (data)

    if !data[ Ticket.to_app_model ]
      data[ Ticket.to_app_model ] = {}
    end
    if !data[ Ticket.to_app_model ][ self.ticket_id ]
      ticket = Ticket.find( self.ticket_id )
      data = ticket.assets(data)
    end

    if !data[ Ticket::Article.to_app_model ]
      data[ Ticket::Article.to_app_model ] = {}
    end
    if !data[ Ticket::Article.to_app_model ][ self.id ]
      data[ Ticket::Article.to_app_model ][ self.id ] = self.attributes

      # add attachment list to article
      data[ Ticket::Article.to_app_model ][ self.id ]['attachments'] = self.attachments
    end

    ['created_by_id', 'updated_by_id'].each {|item|
      if self[ item ]
        if !data[ User.to_app_model ] || !data[ User.to_app_model ][ self[ item ] ]
          user = User.lookup( :id => self[ item ] )
          data = user.assets( data )
        end
      end
    }
    data
  end

end