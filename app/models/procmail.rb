module Procmail
  def load_rule(line)
    line =~ /\^(.*?)\.\*(.*)/
    rule = Rule.new
    rule.section($1)
    rule.substance($2)
  end
end
