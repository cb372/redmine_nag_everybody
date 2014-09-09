# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'mail_options', :to => 'mail_options#index'
post 'mail_options/:id/edit', :to => 'mail_options#edit'
