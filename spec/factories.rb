Factory.define :locale do |f|
  f.title "en"
end

Factory.define :translation do |f|
  f.association :locale
  f.key "welcome"
  f.value "Welcome!"
end

Factory.define :user do |f|
  f.sequence(:email){|n| "default#{n}@email.com"}
  f.password "abc123"
end
