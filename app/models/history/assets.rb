# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

module History::Assets

=begin

get all assets / related models for this history entry

  history = History.find(123)
  result = history.assets( assets_if_exists )

returns

  result = {
    :users => {
      123  => user_model_123,
      1234 => user_model_1234,
    }
  }

=end

  def assets (data)

    if !data[ User.to_app_model ] || !data[ User.to_app_model ][ self['created_by_id'] ]
      user = User.lookup( :id => self['created_by_id'] )
      data = user.assets( data )
    end

    data
  end

end