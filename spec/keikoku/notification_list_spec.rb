require 'spec_helper'

module Keikokuc
  shared_context 'specs with a fake client' do
    let(:fake_client) { double(:fake_client) }
  end
  shared_context 'with user notifications' do
    let(:user_notifications) do
      [
        {
          id:           1,
          target_name:  'flying-monkey-123',
          message:      'Database HEROKU_POSTGRESQL_BROWN is over row limits',
          url:          'https://devcenter.heroku.com/how-to-fix-problem',
          severity:     'info'
        },
        {
          id:           2,
          target_name:  'rising-cloud-42',
          message:      'High OOM rates',
          url:          'https://devcenter.heroku.com/oom',
          severity:     'fatal'
        }
      ]
    end
  end

  describe NotificationList, '#fetch' do
    include_context 'specs with a fake client'
    include_context 'with user notifications'
    it 'finds all notifications for the current user' do
      fake_client.should_receive(:get_notifications).
        and_return([user_notifications, nil])
      list = build(:notification_list, client: fake_client)

      result = list.fetch
      expect(result).to be_true

      expect(list.size).to eq(2)
      list.each do |notification|
        expect(user_notifications.map do |h|
          h[:message]
        end).to include(notification.message)
        expect(notification).to be_kind_of(Notification)
      end
    end

  end

  describe NotificationList, '#read_all' do
    include_context 'specs with a fake client'
    include_context 'with user notifications'

    it 'marks all notifications as read' do
      fake_client.stub(get_notifications: [user_notifications, nil])

      now = Time.now
      fake_client.should_receive(:read_notification).with(1).
        and_return([{read_at: now}, nil])
      fake_client.should_receive(:read_notification).with(2).
        and_return([{read_at: now}, nil])

      list = build(:notification_list, client: fake_client)

      list.fetch or raise "error fetching"

      expect(list.read_all).to be_true

      list.each do |notification|
        expect(notification).to be_read
        expect(notification.read_at).to eq(now)
      end
    end

    it 'returns false if any notification fails to be marked as read' do
      fake_client.stub(get_notifications: [user_notifications, nil])

      now = Time.now
      fake_client.should_receive(:read_notification).with(1).
        and_return([{read_at: now}, nil])
      fake_client.should_receive(:read_notification).with(2).
        and_return([[], :an_error])

      list = build(:notification_list, client: fake_client)

      list.fetch or raise "error fetching"

      expect(list.read_all).to be_false
    end

  end
end
