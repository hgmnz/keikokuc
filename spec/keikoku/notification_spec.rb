require 'spec_helper'

module Keikokuc
  describe Notification, '#publish' do
    it 'publishes to keikoku and stores an id' do
      fake_client = double
      fake_client.
        should_receive(:post_notification).with do |args|
          args[:message].should == 'hello'
          args[:account_email].should == 'harold@heroku.com'
        end.and_return([{ id: 1 }, nil])

      notification = build(:notification, message: 'hello',
                                          account_email: 'harold@heroku.com',
                                          client: fake_client)

      result = notification.publish
      result.should be_true

      notification.remote_id.should == 1
    end

    it 'returns false when publishing fails and stores errors' do
      fake_client = double
      fake_client.
        should_receive(:post_notification).with do |args|
          args[:message].should be_nil
        end.
        and_return([{ errors: { attributes: { message: ['is not present'] }}},
                   Keikokuc::Client::InvalidNotification])

      notification = build(:notification, message: nil, client: fake_client)

      result = notification.publish
      result.should be_false

      notification.remote_id.should be_nil
      notification.errors[:attributes][:message].should == ['is not present']
    end

    it 'stores attributes as instance vars' do
      notification = Notification.new(message: 'foo')
      notification.message.should == 'foo'
    end
  end

  describe Notification, '#read' do
    it 'marks as read to keikoku' do
      fake_client = double

      fake_client.should_receive(:read_notification).
        with('1234').
        and_return([{read_at: Time.now}, nil])

      notification = Notification.new(remote_id: '1234', client: fake_client)

      result = notification.read
      result.should be_true

      notification.read_at.should_not be_nil
      notification.should be_read
    end

    it 'handles errors' do
      fake_client = double
      fake_client.stub(:read_notification).
        with('1234').
        and_return([{}, :some_error])

      notification = Notification.new(remote_id: '1234', client: fake_client)

      result = notification.read
      result.should be_false

      notification.read_at.should be_nil
      notification.should_not be_read
    end
  end

  describe Notification, '#read?' do
    it 'is true if the read_at is known' do
      notification = build(:notification, read_at: nil)
      notification.read?.should be_false

      notification.read_at = Time.now

      notification.read?.should be_true
    end
  end

  describe Notification, '#client' do
    it 'defaults to a properly constructer Keikokuc::Client' do
      notification = build(:notification, producer_api_key: 'fake-api-key')
      notification.client.should be_kind_of Keikokuc::Client
      notification.client.producer_api_key.should == 'fake-api-key'
    end

    it 'can be injected' do
      notification = Notification.new(client: :foo)
      notification.client.should == :foo
    end
  end
end
