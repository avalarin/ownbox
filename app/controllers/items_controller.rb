class ItemsController < ApplicationController
  include DataItemHelper
  attr_reader :target_user, :item_path, :service, :item

  before_filter :authorize
  before_action do
    @target_user = get_user
    @item_path = get_path

    if (!target_user || target_user.id != current_user.id)
      @service = SharedDataService.new current_user, target_user
    else
      @service = PrivateDataService.new current_user 
    end
    @item = service.get_item item_path
    unless @item
      render_not_found
      false
    end
  end

  private

  def get_user
    if (params['user_name'] == :current_user)
      current_user
    elsif params['user_name']
      User.find_by_name(params['user_name'])
    else
      nil
    end
  end

  def get_path
    path = params['path'] || ''
    Path.parse path
  end
end