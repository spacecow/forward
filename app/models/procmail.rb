module Procmail
  def load_rule(line,filter)
    line           =~ /\^(.*?):?\.\*(.*)/
    rule           = Rule.new
    rule.section   = $1
    rule.substance = $2
    filter.rules << rule
  end
end
