Cla::Application.routes.draw do
  root :to => 'pages#index'

  match ':controller(/:action(/:id(.:format)))'
  match 'cla/:github_login/:repo_name/sign' => 'cla#sign'
  match 'cla/:github_login/:repo_name/process_form' => 'cla#process_form'
  match 'cla/:github_login/:repo_name/affix_signature' => 'cla#affix_signature'
  match 'cla/show/:login/:repo_name' => 'cla#show'
  match 'cla/signers/:login/:repo_name' => 'cla#signers'
end
