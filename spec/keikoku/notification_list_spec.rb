require 'spec_helper'

module Keikokuc
  describe NotificationList, '#fetch' do
    it 'finds all notifications for the current user' do
      fake_client = double
      fake_client.should_receive(:get_notifications).
        and_return([user_notifications, nil])
      list = build(:notification_list, client: fake_client)

      result = list.fetch
      result.should be_true

      list.size.should == 2
      list.each do |notification|
        user_notifications.map do |h|
          h[:message]
        end.should include notification.message
        notification.should be_kind_of Notification
      end
    end

    def user_notifications
      [
        {
          resource: 'flying-monkey-123',
          message:  'Database HEROKU_POSTGRESQL_BROWN is over row limits',
          url:      'https://devcenter.heroku.com/how-to-fix-problem',
          severity: 'info'
        },
        {
          resource: 'rising-cloud-42',
          message:  'High OOM rates',
          url:      'https://devcenter.heroku.com/oom',
          severity: 'fatal'
        }
      ]
    end
  end
end
