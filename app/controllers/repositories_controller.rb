class RepositoriesController < ApplicationController
  
  def index
    @org_public_repos = {}
    @orgs = JSON.parse(RestClient.get("https://api.github.com/user/orgs", "Authorization" => "token #{session[:auth_token]}"))
    for org in @orgs
      @org_public_repos[org["login"]] =  JSON.parse(RestClient.get("https://api.github.com/orgs/#{org["login"]}/repos", "Authorization" => "token #{session[:auth_token]}"))
    end
    @repos = JSON.parse(RestClient.get("https://api.github.com/user/repos", "Authorization" => "token #{session[:auth_token]}"))
  end
  
end
