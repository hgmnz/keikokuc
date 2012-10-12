require 'spec_helper'
require 'sham_rack'
module Keikokuc
  shared_context 'client specs' do
    let(:fake_keikoku) { FakeKeikoku.new }
    after { ShamRack.unmount_all }
  end

  describe Client, '#post_notification' do
    include_context 'client specs'

    it 'publishes a new notification' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_publisher({api_key: 'abc'})
      client = Client.new(producer_api_key: 'abc')
      result, error = client.post_notification(message:  'hello',
                                               severity: 'info')
      result[:id].should_not be_nil
      error.should be_nil
    end

    it 'handles invalid notifications' do
      ShamRack.at('keikoku.herokuapp.com', 443) do |env|
        [422, {}, StringIO.new(Yajl::Encoder.encode({ errors: :srorre }))]
      end

      response, error = Client.new.post_notification({})
      error.should == Client::InvalidNotification
      response[:errors].should == 'srorre'
    end

    it 'handles authentication failures' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_publisher({api_key: 'abc'})
      client = Client.new(producer_api_key: 'bad one')
      result, error = client.post_notification(message:  'hello',
                                               severity: 'info')
      result[:id].should be_nil
      error.should == Client::Unauthorized
    end

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:post).and_raise Timeout::Error
      response, error = Client.new.post_notification({})
      response.should be_nil
      error.should == Client::RequestTimeout
    end
  end

  describe Client, '#get_notifications' do
    include_context 'client specs'

    it 'gets all notifications for a user' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_publisher(api_key: 'abc')
      fake_keikoku.register_user(email: 'harold@heroku.com', password: 'pass')
      build(:notification, account_email: 'harold@heroku.com', message: 'find me!', producer_api_key: 'abc').publish
      build(:notification, account_email: 'another@heroku.com', producer_api_key: 'abc').publish

      client = Client.new(user: 'harold@heroku.com', password: 'pass')

      notifications, error = client.get_notifications

      error.should be_nil
      notifications.should have(1).item

      notifications.first[:message].should == 'find me!'
    end

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:get).and_raise Timeout::Error
      response, error = Client.new.get_notifications
      response.should be_nil
      error.should == Client::RequestTimeout
    end

    it 'handles authentication failures' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_user(email: 'harold@heroku.com', password: 'pass')
      client = Client.new(user: 'harold@heroku.com', password: 'bad-pass')

      response, error = client.get_notifications

      response.should be_empty
      error.should == Client::Unauthorized
    end
  end

  describe Client, '#read_notification' do
    include_context 'client specs'
    it 'marks the notification as read' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_publisher(api_key: 'abc')
      fake_keikoku.register_user(email: 'harold@heroku.com', password: 'pass')
      client = Client.new(user: 'harold@heroku.com', password: 'pass')
      notification = build(:notification, account_email: 'harold@heroku.com', producer_api_key: 'abc')
      notification.publish or raise "Notification publish error"

      response, error = client.read_notification(notification.remote_id)
      error.should be_nil

      response[:read_by].should == 'harold@heroku.com'
      response[:read_at].should_not be_nil
    end

    it 'handles authentication errors' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_user(email: 'harold@heroku.com', password: 'pass')
      client = Client.new(user: 'harold@heroku.com', password: 'bad-pass')
      response, error = client.read_notification(1)
      response.should be_empty
      error.should == Client::Unauthorized
    end

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:post).and_raise Timeout::Error
      response, error = Client.new.read_notification(1)
      response.should be_nil
      error.should == Client::RequestTimeout
    end
  end
end
