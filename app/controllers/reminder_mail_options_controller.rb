class ReminderMailOptionsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
  end

  def edit
    options = NagEverybodyOptions.find(params[:id])
    options.send_to_watchers = !params[:send_to_watchers].nil?

    if options.save
      flash[:notice] = "Saved Options"
    end

    redirect_to request.referer
  end
end
