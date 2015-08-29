# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

class ObjectManagerAttributesController < ApplicationController
  before_action :authentication_check

  # GET /object_manager_attributes_list
  def list
    return if deny_if_not_role(Z_ROLENAME_ADMIN)
    render json: {
      objects: ObjectManager.list_frontend_objects,
    }
    #model_index_render(ObjectManager::Attribute, params)
  end

  # GET /object_manager_attributes
  def index
    return if deny_if_not_role(Z_ROLENAME_ADMIN)
    render json: ObjectManager::Attribute.list_full
    #model_index_render(ObjectManager::Attribute, params)
  end

  # GET /object_manager_attributes/1
  def show
    return if deny_if_not_role(Z_ROLENAME_ADMIN)
    model_show_render(ObjectManager::Attribute, params)
  end

  # POST /object_manager_attributes
  def create
    return if deny_if_not_role(Z_ROLENAME_ADMIN)
    model_create_render(ObjectManager::Attribute, params)
  end

  # PUT /object_manager_attributes/1
  def update
    return if deny_if_not_role(Z_ROLENAME_ADMIN)
    model_update_render(ObjectManager::Attribute, params)
  end

  # DELETE /object_manager_attributes/1
  def destroy
    return if deny_if_not_role(Z_ROLENAME_ADMIN)
    model_destory_render(ObjectManager::Attribute, params)
  end
end