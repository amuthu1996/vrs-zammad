# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

class ObjectManager

=begin

add a new activity entry for an object

  ObjectManager.listObjects()

=end

  def self.listObjects
    ['Ticket', 'TicketArticle', 'Group', 'Organization', 'User']
  end

end

class ObjectManager::Attribute < ApplicationModel
  self.table_name = 'object_manager_attributes'
  belongs_to :object_lookup,   :class_name => 'ObjectLookup'
  validates               :name, :presence => true
  store                   :screens
  store                   :data_option


=begin

add a new activity entry for an object

  ObjectManager::Attribute.add(
    :object     => 'Ticket',
    :name       => 'group_id',
    :frontend   => 'Group',
    :data_type  => 'select',
    :data_option => {
      :relation => 'Group',
      :relation_condition => { :access => 'rw' },
      :multiple => false,
      :null     => true,
    },
    :editable           => false,
    :active             => true,
    :screens            => {
      :create => {
        '-all-' => {
          :required => true,
        },
      },
      :edit => {
        :Agent => {
          :required => true,
        },
      },
    },
    :pending_migration  => false,
    :position           => 20,
    :created_by_id      => 1,
    :updated_by_id      => 1,
    :created_at         => '2014-06-04 10:00:00',
    :updated_at         => '2014-06-04 10:00:00',
  )


=end

  def self.add(data)

    # lookups
    if data[:object]
      data[:object_lookup_id] = ObjectLookup.by_name( data[:object] )
    end
    data.delete(:object)

    # check newest entry - is needed
    result = ObjectManager::Attribute.where(
      :object_lookup_id            => data[:object_lookup_id],
      :name                        => data[:name],
    ).first
    if result
#      raise "ERROR: attribute #{data[:name]} for #{data[:object]} already exists"
      return result.update_attributes(data)
    end

    # create history
    ObjectManager::Attribute.create(data)
  end


=begin

get list of object attributes

  attribute_list = ObjectManager::Attribute.by_object('Ticket', user)

returns:

  [
    { :name => 'api_key', :display => 'API KEY', :tag => 'input', :null => true, :edit => true, :maxlength => 32 },
    { :name => 'api_ip_regexp', :display => 'API IP RegExp', :tag => 'input', :null => true, :edit => true },
    { :name => 'api_ip_max', :display => 'API IP Max', :tag => 'input', :null => true, :edit => true },
  ]

=end

  def self.by_object(object, user)

    # lookups
    if object
      object_lookup_id = ObjectLookup.by_name( object )
    end

    # get attributes in right order
    result = ObjectManager::Attribute.where(
      :object_lookup_id => object_lookup_id,
      :active => true,
    ).order('position ASC')
    attributes = []
    result.each {|item|
      data = {
        :name     => item.name,
        :display  => item.display,
        :tag      => item.data_type,
        #:null     => item.null,
      }
      if item.screens
        data[:screen] = {}
        item.screens.each {|screen, roles_options |
          data[:screen][screen] = {}
          roles_options.each {|role, options|
            if role == '-all-'
              data[:screen][screen] = options
            elsif user && user.is_role(role)
              data[:screen][screen] = options
            end
          }
        }
      end
      if item.data_option
        data = data.merge( item.data_option )
      end
      attributes.push data
    }
    attributes
  end

end