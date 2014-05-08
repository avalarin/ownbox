class ItemsController < ApplicationController
  include DataItemHelper
  attr_reader :target_user, :item_path, :service, :item
  before_filter :authorize
  before_action do
    @target_user = get_user
    @item_path = get_path
    @service = DataService.new current_user, target_user 
    @item = service.get_item item_path

    if !@item
      render_not_found
      false
    end
  end

  private

  def get_user
    if (params['user_name'] == :current_user)
      current_user
    else
      User.find_by_name(params['user_name'])
    end
  end

  def get_path
    path = params['path'] || ''
    Path.parse path
  end
end