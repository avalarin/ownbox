class Settings::SharesController < ApplicationController
  layout "settings"
    
  before_filter :authorize

  def index
    @items = Share.get_by_user current_user
    @m = Settings::SharesController.included_modules
    if request.xhr?
      json_items = @items.collect { |i| wrap_share i }
      return render json: { items: json_items } 
    end
  end

  def create
    share_params = params.require(:share).permit(:name, :path)
    share = Share.new share_params
    share.user = current_user

    exist_share = Share.find_by_user_and_name current_user, share_params[:name]
    if exist_share
      share.errors[:name] << t('errors.messages.share_already_exists')
      return render_model_errors_api_resp share
    end
    if share.valid?
      share.save!
      render_api_resp :ok, data: wrap_share(share)
    else
      render_model_errors_api_resp share
    end
  end

  def update
    share_params = params.require(:share).permit(:id, :name, :path)
    share = Share.find_by_id(share_params[:id].to_i)
    return render_api_resp :not_found unless share

    exist_share = Share.find_by_user_and_name current_user, share_params[:name]
    if exist_share
      share.errors[:name] << t('errors.messages.share_already_exists')
      return render_model_errors_api_resp share
    end
    
    share[:name] = share_params[:name]
    share[:path] = share_params[:path]
    share.save!
    render_api_resp :ok
  end

  def delete
    id = params[:id].to_i
    share = Share.find_by_id(id)
    return render_api_resp :not_found unless share
    share.delete
    render_api_resp :ok
  end

  private

  def wrap_share share
    { id: share.id, name: share.name, path: share.path }
  end

end
