FactoryGirl.define do
  factory :notification, class: Keikokuc::Notification do
    skip_create

    message       'Your database is over limits'
    target_name   'cloudy-skies-243'
    severity      'info'
    account_email 'harold@heroku.com'
  end
end
