require 'spec_helper'

module Keikokuc
  describe Notification, '#publish' do
    it 'publishes to keikoku and stores an id' do
      fake_client = double
      Client.stub(new: fake_client)
      fake_client.
        should_receive(:post_notification).with do |args|
          args[:message].should == 'hello'
        end.
        and_return([{ id: 1 }, true])

      notification = build(:notification, message: 'hello')

      result = notification.publish
      result.should be_true

      notification.remote_id.should == 1
    end

    it 'returns false when publishing fails and stores errors' do
      fake_client = double
      Client.stub(new: fake_client)
      fake_client.
        should_receive(:post_notification).with do |args|
          args[:message].should be_nil
        end.
        and_return([{ errors: { attributes: { message: ['is not present'] }}}, false])

      notification = build(:notification, message: nil)

      result = notification.publish
      result.should be_false

      notification.remote_id.should be_nil
      notification.errors[:attributes][:message].should == ['is not present']
    end
  end
end
