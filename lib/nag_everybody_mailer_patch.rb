module NagEverybodyMailerPatch
  def self.included(base) # :nodoc:

    # Add class methods
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

        by_assignee_scope = Issue.open.where("#{Issue.table_name}.assigned_to_id IS NOT NULL" +
          " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
          " AND #{Issue.table_name}.due_date <= ?", days.day.from_now.to_date
        )
        by_assignee_scope = by_assignee_scope.where(:assigned_to_id => user_ids) if user_ids.present?
        by_assignee_scope = by_assignee_scope.where(:project_id => project.id) if project
        by_assignee_scope = by_assignee_scope.where(:tracker_id => tracker.id) if tracker
        issues_by_assignee = by_assignee_scope.includes(:status, :assigned_to, :project, :tracker).
                                  group_by(&:assigned_to)
        issues_by_assignee.keys.each do |assignee|
          if assignee.is_a?(Group)
            assignee.users.each do |user|
              issues_by_assignee[user] ||= []
              issues_by_assignee[user] += issues_by_assignee[assignee]
            end
          end
        end

        by_watcher_scope = Issue.open.where(
          "#{Project.table_name}.status = #{Project::STATUS_ACTIVE}" +
          " AND #{Issue.table_name}.due_date <= ?", days.day.from_now.to_date
        )
        by_watcher_scope = by_watcher_scope.where("EXISTS(SELECT 1 FROM watchers WHERE watchable_id = issues.id AND watchable_type = 'Issue' AND user_id IN (?))", user_ids) if user_ids.present?
        by_watcher_scope = by_watcher_scope.where(:project_id => project.id) if project
        by_watcher_scope = by_watcher_scope.where(:tracker_id => tracker.id) if tracker
        issues = by_watcher_scope.includes(:status, :watchers, :project, :tracker)
        issues_by_watcher = {}
        issues.each do |issue|
          issue.watchers.each do |watcher|
            user = User.find_by_id(watcher.user_id)
            issues_by_watcher[user] ||= []
            issues_by_watcher[user] << issue
          end
        end

        # TODO Remove any watched issues for projects that don't have this plugin enabled

        # combine issues_by_watcher and issues_by_assignee
        issues_by_user = {}
        (issues_by_assignee.keys + issues_by_watcher.keys).to_set.each do |user|
          assigned = issues_by_assignee[user] || []
          watching = issues_by_watcher[user] || []

          # Filter out any duplicates 
          # (i.e. issues that the user is both assigned to and watching)
          watching = watching.select{ |i| !assigned.include? i }
          issues_by_user[user] = { :assigned => assigned, :watching => watching }
        end

        issues_by_user.each do |user, issues|
          extended_reminder(user, issues[:assigned], issues[:watching], days).deliver if user.is_a?(User) && user.active?
        end
      end

    end

    # Add instance methods
    base.class_eval do

      # Send a reminder email including both assigned and watched issues
      def extended_reminder(user, assigned_issues, watched_issues, days)
        puts "Sending reminder mail to #{user.mail}"
        set_language_if_valid user.language
        @assigned_issues = assigned_issues
        @watched_issues = watched_issues
        @days = days
        @assigned_issues_url = url_for(:controller => 'issues', :action => 'index',
                                    :set_filter => 1, :assigned_to_id => user.id,
                                    :sort => 'due_date:asc')
        @watched_issues_url = url_for(:controller => 'issues', :action => 'index',
                                    :set_filter => 1, :watcher_id => user.id,
                                    :sort => 'due_date:asc')
        mail :to => user.mail,
          :subject => l(:mail_subject_reminder, :count => assigned_issues.size + watched_issues.size, :days => days)
      end

    end

  end

end
