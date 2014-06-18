module Admin
  class AdminBaseController < ApplicationController
    layout "admin"

    before_filter { authorize :admin }
  end
end