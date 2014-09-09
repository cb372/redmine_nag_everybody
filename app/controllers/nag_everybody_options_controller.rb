class NagEverybodyOptionsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    @mail_options = MailOptions.all
  end

  def edit
    mail_options = MailOptions.find(params[:id])
    mail_options.send_on_create = !params[:send_on_create].nil?
    mail_options.send_on_assignee_change = !params[:send_on_assignee_change].nil?
    mail_options.send_on_comment = !params[:send_on_comment].nil?
    mail_options.send_on_file_upload = !params[:send_on_file_upload].nil?
    mail_options.send_on_subject_change = !params[:send_on_subject_change].nil?
    mail_options.send_on_tracker_change = !params[:send_on_tracker_change].nil?

    if mail_options.save
      flash[:notice] = "Saved Options"
    end

    #redirect_to :action => 'index'
    redirect_to request.referer
  end
end
