module Procmail
  def prepare_filters(username, password)
    @filters = read_filters(username,password)
    current_user.filters.destroy_all
    current_user.filters = @filters
  end

  def read_filters(username, password)
    IO.popen("/usr/local/sbin/chprocmailrc -g #{username}", 'r+') do |pipe|
      pipe.write(password)
      pipe.close_write
      load_filters(pipe.read)
    end
  end

  def save_filters(username, password, arr)
    IO.popen("/usr/local/sbin/chprocmailrc -s #{username}", 'r+') do |pipe|
      pipe.write "#{password}\n"
      pipe.write "MAILDIR=$HOME/Maildir/\n"
      pipe.write "DEFAULT=$MAILDIR\n\n"
      pipe.write arr.map(&:to_file).join("\n\n")
      pipe.write "\n"
      pipe.close_write
    end
  end

  def load_filters(lines)
    filters = []
    arr = lines.split("\n")
    while line = arr.shift
      filters << load_filter(line,arr) if line =~ /^:0/
    end
    filters
  end

  def load_filter(recipe,arr)
    filter = Filter.new
    while line = arr.shift
      return filter if line.blank?
      if line =~ /^\*/
        load_rule(line,filter)
      else
        load_action(recipe,line,filter)
      end
    end
    filter
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
    line           =~ /\^?(Subject|To|CC|From):?\s?(.*)/
    rule           = Rule.new
    rule.section   = $1
    rule.substance = strip_substance($2)
    rule.part      = load_part($2)
    filter.rules << rule
  end

  def load_action(recipe,line,filter)
    action             = Action.new
    if line =~ /^!/
      action.operation = "Forward " + (recipe.include?("c") ? "Copy" : "Message") + " to"
    else
      action.operation = (recipe.include?("c") ? "Copy" : "Move") + " Message to"
    end
    action.destination = strip_destination(line) #prepare_destination(line)
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
