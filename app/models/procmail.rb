module Procmail
  def prepare_filters(username, password)
   # IO.popen("/usr/local/sbin/chprocmailrc -g #{username}", 'r+') do |pipe|
   #   pipe.write(password)
   #   pipe.close_write
   #   @filters = load_filters(pipe.read)
   # end
    read_filters(username,password)
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
      pipe.close_write
    end
  end

  def load_filters(lines)
    filters = []
    filter = nil
    recipe,rule,action = "", "", ""
    lines.split("\n").each do |line|
      if line.blank?
        recipe = ""
      elsif line =~ /^:0/
        recipe = line
        filters << load_filter(recipe,rule,action) if filter 
        filter = Filter.new
      elsif line =~ /^\*/ and recipe.present?
        rule = line
      elsif recipe.present?
        action = line
      end
    end
    filters << load_filter(recipe,rule,action) if filter
    filters
  end

  def load_filter(recipe,rule,action)
    filter = Filter.new
    load_rule(rule,filter)
    load_action(recipe,action,filter)
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
    action.operation = (recipe.include?("c") ? "Copy" : "Move") + " Message to"
    if line =~ /^\./
      if line =~ /\/$/
        action.destination = line 
      else
        action.destination = "#{line}/"
      end
    elsif line =~ /\/$/
      action.destination = ".#{line}"
    else
      action.destination = ".#{line}/"
    end
    filter.actions << action
  end
end
