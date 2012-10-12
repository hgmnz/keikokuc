FactoryGirl.define do
  factory :notification, :class => Keikokuc::Notification do
    skip_create

    message       'Your database is over limits'
    target_name   'cloudy-skies-243'
    severity      'info'
    account_email 'harold@heroku.com'

    initialize_with { new(attributes) }
  end

  factory :notification_list, :class => Keikokuc::NotificationList do
    skip_create

    user     'user@example.com'
    password 'pass'

    initialize_with { new(attributes) }
  end
end
