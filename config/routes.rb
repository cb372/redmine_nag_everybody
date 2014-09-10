# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'reminder_mail_options', :to => 'reminder_mail_options#index'
post 'reminder_mail_options/:id/edit', :to => 'reminder_mail_options#edit'
