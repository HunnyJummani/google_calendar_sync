module SessionsHelper
  def user_emails
    User.pluck(:email).reject{ |mail| mail == current_user.email }
  end
end
