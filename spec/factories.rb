Factory.define :action do |f|
end

Factory.define :filter do |f|
end

Factory.define :locale do |f|
  f.title "en"
end

Factory.define :rule do |f|
end

Factory.define :translation do |f|
  f.association :locale
  f.key "welcome"
  f.value "Welcome!"
end

Factory.define :user do |f|
  f.sequence(:username){|n| "username#{n}"}
  f.password "abc123"
end
