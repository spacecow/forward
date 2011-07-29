module Procmail
  def load_filters(lines)
    filters = []
    filter = nil
    start = false
    lines.split("\n").each do |line|
      if line.blank?
        start = false
      elsif line =~ /^:0/
        start = true
        filters << filter if filter 
        filter = Filter.new
      elsif line =~ /^\*/ and start
        load_rule(line,filter)
      elsif start
        load_action(line,filter)
      end
    end
    filters << filter if filter
    filters
  end

  def load_filter(rule,action)
    filter = Filter.new
    load_rule(rule,filter)
    load_action(action,filter)
    filter
  end

  def load_action(s,filter)
    action             = Action.new
    action.operation   = "Move Message to"
    action.destination = s
    filter.actions << action
  end

  def load_part(s)
    if s =~ /^\.\*(.*)/
      if s =~ /(.*)\.\*$/
        "contains"
      elsif s =~ /(.*)\$$/
        "ends with"
      else
        "contains"
      end
    elsif s =~ /(.*)\.\*$/
      "begins with"
    elsif s =~ /(.*)\$$/
      "is"
    else
      "begins with"
    end
  end

  def strip_substance(s)
    s = s[2..-1] if s =~ /^\.\*(.*)/
    s = s[0..-3] if s =~ /(.*)\.\*$/
    s = s[0..-2] if s =~ /(.*)\$$/
    s
  end

  def load_rule(line,filter)
    line           =~ /\^?(To|CC|From):?\s?(.*)/
    rule           = Rule.new
    rule.section   = $1
    rule.substance = strip_substance($2)
    rule.part      = load_part($2)
    filter.rules << rule
  end
end
