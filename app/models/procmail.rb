module Procmail
  def prepare_filters(username, password)
    @filters = read_filters(username, password)
    current_user.filters.destroy_all
    current_user.filters = @filters
    raise FilterCreationException, "Filter id is nil." if current_user.filters.map(&:id).include?(nil)
  end

  def read_filters(username, password)
    IO.popen("/usr/local/sbin/chprocmailrc -g #{username}", 'r+') do |pipe|
      pipe.write(password)
      pipe.close_write
      load_filters(pipe.read)
    end
  end

  def save_filters(username, password, arr)
    IO.popen("/usr/local/sbin/chprocmailrc -s #{username}", 'w+') do |pipe|
      pipe.write "#{password}\n"
      #pipe.write "MAILDIR=$HOME/Maildir/\n"
      #pipe.write "DEFAULT=$MAILDIR\n\n"
      pipe.write session[:prolog]
      pipe.write arr.map(&:to_file).join("\n\n")
      pipe.write "\n"
      pipe.close_write
    end
  end

  def load_filters(lines)
    filters = []
    arr = lines.split("\n")
    prolog = []
    rule_definition = false
    while line = arr.shift
      if line =~ /^:0/
        rule_definition = true
        filters << load_filter(line,arr)
      end
      prolog.push line unless rule_definition 
    end
    session[:prolog] = "#{prolog.join("\n")}\n"
    filters
  end

  def load_filter(recipe,arr)
    filter = Filter.new
    action = false
    while line = arr.shift
      return filter if line.blank? and !action
      if line =~ /^\*/
        load_rule(line,filter)
      elsif line =~ /{/
        action = true
      elsif line =~ /}/
        action = false
      else
        if line =~ /:0/ 
          recipe = line
        elsif !line.blank?
          load_action(recipe,line,filter)
        end
      end
    end
    filter
  end

  def load_rule(line,filter)
    line           =~ /^\*\^([a-zA-Z(\-|)]+):?\s*(.+)/
    rule           = Rule.new
    rule.section   = Rule.map_section($1)
    rule.substance = strip_substance($2)
    rule.part      = load_part($2)
    filter.rules << rule
  end

  def load_part(s)
    if s =~ /^\.\*(.*)/
      if s =~ /(.*)\.\*$/
        Rule::CONTAINS 
      elsif s =~ /(.*)\$$/
        Rule::ENDS_WITH
      else
        Rule::CONTAINS
      end
    elsif s =~ /(.*)\.\*$/
      Rule::BEGINS_WITH
    elsif s =~ /(.*)\$$/
      Rule::IS
    else
      Rule::BEGINS_WITH
    end
  end

  def strip_substance(s)
    s = s[2..-1] if s =~ /^\.\*(.*)/
    s = s[0..-3] if s =~ /(.*)\.\*$/
    s = s[0..-2] if s =~ /(.*)\$$/
    s
  end

  def load_action(recipe,line,filter)
    action             = Action.new
    line = line.strip
    if line =~ /^!/
      if recipe.include?("c")
        action.operation = Action::FORWARD_COPY_TO
      else
        action.operation = Action::FORWARD_MESSAGE_TO
      end
    else
      if recipe.include?("c")
        action.operation = Action::COPY_MESSAGE_TO
      else
        action.operation = Action::MOVE_MESSAGE_TO
      end 
    end
    action.destination = strip_destination(line) 
    if action.forward_message? && !action.resembles_email?
      raise InvalidEmailException, "Destination email must be valid." 
    end

    filter.actions << action
  end

  def strip_destination(s)
    data = s.match(/^!\s*(.*)/)
    return data[1] if data
    data = s.match(/^\.(.*)\//)
    return data[1] if data
    data = s.match(/(.+)\//)
    return data[1] if data
    data = s.match(/\.(.*)/)
    return data[1] if data
    s
  end

  def prepare_destination(s)
    if      data = s.match(/^!\s?(.*)/); data[1]    #mail, strip !
    elsif   s =~ /^\./
      if    s =~ /\/$/;                  s 
      else;                              s+"/"
      end
    elsif   s =~ /\/$/;                  "."+s
    else;                                "."+s+"/"
    end
  end
end
