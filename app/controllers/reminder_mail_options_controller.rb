class ReminderMailOptionsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    @options = NagEverybodyOptions.find_or_create_by_project_id(@project.id)
  end

  def edit
    options = NagEverybodyOptions.find(params[:id])
    options.send_to_watchers = !params[:send_to_watchers].nil?
    options.save!

    flash[:notice] = "Saved Options"
    redirect_to request.referer
  end
end
