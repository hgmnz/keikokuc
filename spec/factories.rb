FactoryGirl.define do
  factory :notification, class: Keikokuc::Notification do
    skip_create

    message  'Your database is over limits'
    target   'cloudy-skies-243'
    severity 'info'
  end
end
