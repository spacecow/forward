module Validation
  def self.resembles_email?(s)
    s.match(/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/)
  end
end
