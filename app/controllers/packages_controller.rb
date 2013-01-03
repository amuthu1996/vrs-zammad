class PackagesController < ApplicationController
  before_filter :authentication_check

  # GET /api/packages
  def index
    return if is_not_role('Admin')
    packages = Package.all( :order => 'name' )
    render :json => {
      :packages => packages
    }
  end

  # POST /api/packages
  def install
    return if is_not_role('Admin')

    Package.install( :string => params[:file_upload].read )

    redirect_to '/#package'
  end

  # DELETE /api/packages
  def uninstall
    return if is_not_role('Admin')

    package = Package.find( params[:id] )

    Package.uninstall( :name => package.name, :version => package.version )

    render :json => {
      :success => true
    }
  end

end