require 'spec_helper'
require 'sham_rack'
module Keikokuc
  describe Client, '#post_notification' do
    let(:fake_keikoku) { FakeKeikoku.new }

    after { ShamRack.unmount_all }

    it 'publishes a new notification' do
      ShamRack.mount(fake_keikoku, "keikoku.herokuapp.com", 443)
      fake_keikoku.register_publisher({api_key: 'abc'})
      result, error = Client.new.post_notification(message:  'hello',
                                                     severity: 'info',
                                                     api_key:  'abc')
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

    it 'handles timeouts' do
      RestClient::Resource.any_instance.stub(:post).and_raise Timeout::Error
      response, error = Client.new.post_notification({})
      response.should be_nil
      error.should == Client::RequestTimeout
    end
  end
end
