class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper

  after_filter :store_location
  before_filter :set_locale

  def store_location
    if (request.path != "/members/sign_in" &&
        request.path != "/members/sign_up" &&
        request.path != "/members/password/new" &&
        request.path != "/members/password/edit" &&
        request.path != "/members/confirmation" &&
        request.path != "/members/sign_out" &&
        !request.xhr?)
        store_location_for(:member, request.fullpath)
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:member) || root_path
  end

  # tweak CanCan defaults because we don't have a "current_user" method
  # this means that we use current_user in specs but current_member everywhere
  # else in the code.
  def current_ability
    @current_ability ||= Ability.new(current_member)
  end

  # CanCan error handling
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to request.referer || root_url, :alert => exception.message
  end
   
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # Adds locale query parameter to every path / url helper
  def default_url_options(options={})
    if I18n.locale == :en
      {}
    else
      { locale: I18n.locale }
    end
  end

end
