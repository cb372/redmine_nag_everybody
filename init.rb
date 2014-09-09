Rails.configuration.to_prepare do
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Mailer.included_modules.include? NagEverybodyMailerPatch
    # Use prepend because we want to replace the existing method
    Mailer.send(:include, NagEverybodyMailerPatch)
  end 
end

Redmine::Plugin.register :redmine_nag_everybody do
  name 'Redmine Nag Everybody plugin'
  author 'Chris Birchall'
  description 'Noisier reminder mails for Redmine'
  version '0.1.0'
  url 'https://github.com/cb372/redmine_nag_everybody'

  #project_module :mail_options do 
    #permission :view_mail_options, :mail_options => :index
    #permission :edit_mail_options, :mail_options => :edit
  #end
  #menu :project_menu, :mail_options, { :controller => 'mail_options', :action => 'index' }, :caption => :mail_options, :after => :activity, :param => :project_id
end
