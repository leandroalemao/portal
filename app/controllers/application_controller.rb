class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
  	 respond_to do |format|
  	 	format.html { redirect_to root_url, alert: t('unauthorized.acesso.negado') }
  	 end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
  	 respond_to do |format|
  	 	format.html { redirect_to root_url, alert: t('errors.messages.existe') }
  	 end
  end

end
