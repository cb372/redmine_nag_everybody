module NagEverybodyMailerPatch
  def self.included(base) # :nodoc:
    base.instance_eval do

      # Sends reminders to both issue assignees and issue watchers.
      # Note that this overrides the Redmine Mailer.reminders method, which sends emails only to assignees.
      #
      # Available options:
      # * :days     => how many days in the future to remind about (defaults to 7)
      # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
      # * :project  => id or identifier of project to process (defaults to all projects)
      # * :users    => array of user/group ids who should be reminded
      def reminders(options={})
        puts "Nagging everybody..."

        days = options[:days] || 7
        project = options[:project] ? Project.find(options[:project]) : nil
        tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
        user_ids = options[:users]

        scope = Issue.open.where("#{Issue.table_name}.assigned_to_id IS NOT NULL" +
          " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
          " AND #{Issue.table_name}.due_date <= ?", days.day.from_now.to_date
        )
        scope = scope.where(:assigned_to_id => user_ids) if user_ids.present?
        scope = scope.where(:project_id => project.id) if project
        scope = scope.where(:tracker_id => tracker.id) if tracker
        issues_by_assignee = scope.includes(:status, :assigned_to, :project, :tracker).
                                  group_by(&:assigned_to)
        issues_by_assignee.keys.each do |assignee|
          if assignee.is_a?(Group)
            assignee.users.each do |user|
              issues_by_assignee[user] ||= []
              issues_by_assignee[user] += issues_by_assignee[assignee]
            end
          end
        end

        issues_by_assignee.each do |assignee, issues|
          reminder(assignee, issues, days).deliver if assignee.is_a?(User) && assignee.active?
        end
      end

    end
  end


    #def issue_add_with_fine_grain_settings(issue, to_users, cc_users)
      #project = issue.project
      #issue_mail = issue_add_without_fine_grain_settings(issue, to_users, cc_users)
      ## Make sure the plugin is still enabled
      #unless EnabledModule.find_by_project_id_and_name(project,"mail_options")
        #return issue_mail
      #end

      #mo = MailOptions.find_by_project_id(project)

      ## If turned off, blank the headers
      #unless (mo.nil? or mo.send_on_create)
        #blank_mail
      #end

      ##And return the original value
      #return issue_mail
    #end

    #def issue_edit_with_fine_grain_settings(journal, to_users, cc_users)
      #project = journal.journalized.reload.project
      #issue_mail = issue_edit_without_fine_grain_settings(journal, to_users, cc_users)

      ## Make sure the plugin is enabled before doing anything
      #unless EnabledModule.find_by_project_id_and_name(project,"mail_options")
        #return issue_mail
      #end

      #mo = MailOptions.find_by_project_id(project)

      #unless mo # If there isn't one just do the usual
        #return issue_mail
      #end

      #if journal.notify? &&
        #(
        #(journal.notes.present? && mo.send_on_comment) || 
        #(journal.new_value_for('assigned_to_id').present? && mo.send_on_assignee_change) ||
        #(journal.new_value_for('subject').present? && mo.send_on_subject_change) ||
        #(journal.new_value_for('attachment').present? && mo.send_on_file_upload) ||
        #(journal.new_value_for('tracker_id').present? && mo.send_on_tracker_change)
      #)
        #return issue_mail
      #end
      ## No reason to notice found, disable mail
      #blank_mail
      #return issue_mail
    #end
 
end
