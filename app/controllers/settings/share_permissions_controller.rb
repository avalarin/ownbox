class Settings::SharePermissionsController < ApplicationController
  layout "settings"

  def index
    @share = Share.find_by_id params[:share_id]
    return render_not_found unless @share
    @permissions = SharePermission.where(share_id: @share.id)

    respond_to do |format|
      format.json {render json: @permissions.collect{ | p | wrap_permission p }.to_json }
    end
  end
  
  def update
    @share = Share.find_by_id params[:share_id]
    return render_not_found unless @share
    @new_permissions = params[:permissions] ? params[:permissions].collect do |raw|
      user = User.find_by_name raw["user"]
      SharePermission.new({ share: @share, user: user, permission: raw["permission"] })
    end : []
    return render_api_resp :bad_request if @new_permissions.any? { |p| !p.valid? }
    SharePermission.destroy_all(share_id: @share.id)
    @new_permissions.each { |p| p.save! }
    render_api_resp :ok
  end

  private

  def wrap_permission p
    {
      user: {
        name: p.user.name,
        email: p.user.email,
        displayName: p.user.display_name
      },
      permission: p.permission
    }
  end

end