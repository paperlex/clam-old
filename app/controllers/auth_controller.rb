require 'net/http'
require 'net/https'

class AuthController < ApplicationController
  
  def login
    redirect_to "https://github.com/login/oauth/authorize?client_id=#{OAUTH_CLIENT_ID}"
  end
  
  def oauth
    # begin
      http = Net::HTTP.new("github.com", 443)
      http.use_ssl = true
      path = "/login/oauth/access_token"
      # SystemTimer.timeout_after(2.seconds) do
        res = http.post(path, "client_id=#{OAUTH_CLIENT_ID}&client_secret=#{OAUTH_SECRET}&code=#{params[:code]}")
      # end
      if res.code == "200" and res.body.index("access_token") == 0
        session[:auth_token] = res.body.split("&").first.split("=").last
        github_user = JSON.parse(RestClient.get("https://api.github.com/user", "Authorization" => "token #{session[:auth_token]}"))
        user = User.find_or_create_by_github_id_and_github_login(github_user["id"], github_user["login"])
        user.update_email(github_user["email"])
        session[:current_user] = user.id
        if session[:redirect_to].present?
          return redirect_to(session[:redirect_to])
        end
        if user.contributor_license_agreements.count == 0
          redirect_to "/repositories"
        else
          redirect_to "/cla"
        end
      else
        render :text => "RES: #{res.body}"
      end
    # rescue Exception
    #   render :text => "GitHub authentication is down"
    # end
  end
  
  def logout
    session[:auth_token] = nil
    session[:current_user] = nil
    session[:redirect_to] = nil
    redirect_to "/"
  end
  
end
