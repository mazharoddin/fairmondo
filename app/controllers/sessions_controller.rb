# https://github.com/plataformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb
class SessionsController < Devise::SessionsController
  skip_before_filter :check_new_terms
  layout proc { request.xhr? ? false : 'application_reduced' }, only: :new
end
