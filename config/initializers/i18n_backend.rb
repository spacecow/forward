$redis = Redis.new(:host => 'localhost', :port => 6379)

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::KeyValue.new($redis), I18n.backend)
#I18n.backend = I18n::Backend::KeyValue.new($redis)
