module Procmail
  def prepare_filters(username, password)
    @filters, @prolog = read_filters(username, password)
    current_user.filters.destroy_all
    current_user.filters = @filters
    #raise FilterCreationException, "Filter id is nil." if current_user.filters.map(&:id).include?(nil)
  end

  def read_filters(username, password)
    IO.popen("/usr/local/sbin/chprocmailrc -g #{username}", 'r+') do |pipe|
      pipe.write(password)
      pipe.close_write
      load_filters(pipe.read)
    end
  end

  def save_filters(username, password, prolog, filters)
    IO.popen("/usr/local/sbin/chprocmailrc -s #{username}", 'w+') do |pipe|
      pipe.write "#{password}\n"
      if prolog.blank?
        pipe.write "MAILDIR=$HOME/Maildir/\n"
        pipe.write "DEFAULT=$MAILDIR\n"
        pipe.write "SHELL=/bin/sh\n\n"
      else
        pipe.write "#{prolog}\n"
      end
      if filters.map(&:japanese_subject?).include?(true)
        pipe.write "\n"
        pipe.write ":0:conversion_subject\n"
        pipe.write "*^Subject:\/.*\n"
        pipe.write "SUB=| echo \"$MATCH\" | perl /usr/local/bin/convert_japanese.pl -d\n\n"
      end
      if filters.map(&:japanese_recipient?).include?(true)
        pipe.write "\n"
        pipe.write ":0:conversion_to\n"
        pipe.write "*^To:\/.*\n"
        pipe.write "REC=| echo \"$MATCH\" | perl /usr/local/bin/convert_japanese.pl -d\n\n"
      end
      if filters.map(&:japanese_sender?).include?(true)
        pipe.write "\n"
        pipe.write ":0:conversion_from\n"
        pipe.write "*^From:\/.*\n"
        pipe.write "SEN=| echo \"$MATCH\" | perl /usr/local/bin/convert_japanese.pl -d\n\n"
      end
      if filters.map(&:japanese_cc?).include?(true)
        pipe.write "\n"
        pipe.write ":0:conversion_cc\n"
        pipe.write "*^Cc:\/.*\n"
        pipe.write "CCC=| echo \"$MATCH\" | perl /usr/local/bin/convert_japanese.pl -d\n\n"
      end
      if filters.map(&:japanese_to_or_cc?).include?(true)
        pipe.write "\n"
        pipe.write ":0:conversion_to_or_cc\n"
        pipe.write "*^(To|Cc):\/.*\n"
        pipe.write "TOC=| echo \"$MATCH\" | perl /usr/local/bin/convert_japanese.pl -d\n\n"
      end
      pipe.write filters.map(&:to_file).join("\n\n")
      pipe.write "\n"
      pipe.close_write
    end
  end

  def load_filters(lines)
    filters = []
    arr = lines.split("\n")
    prolog = []
    convs = []
    rule_definition = false
    conv_definition = false
    while line = arr.shift
      if line =~ /^:0:conversion/
        conv_definition = true
      elsif line =~ /^:0/
        rule_definition = true
        filters << load_filter(line,arr)
      end
      unless rule_definition
        if conv_definition
          convs.push line
        else
          prolog.push line
        end
      end
    end
    [filters, prolog, convs]
  end

  def load_filter(recipe,arr)
    filter = Filter.new
    backup = arr.split("/n")
    action = false
    while line = arr.shift
      return filter if line.blank? and !action
      if line =~ /^\*/
        load_rule(line,filter)
      elsif line =~ /{ }/
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
    raise RuleLoadException, "Parsing of rule failed for recipe: #{recipe}, rest: #{backup}" if filter.rules.empty?
    filter
  end

  def load_rule(line,filter)
    data = line.match(
      /^    #start
      \*    #first ch is a star
      (\^?) #hat or nothing
      \(    #then a parenthesis
      (.*?)  #anything
      \)    #end parenthesis
      (.*)  #anything
      /x)
    # Parenthesis is around the section
    if data && data[3][0] == ":"
      load_single_rule(line,filter)
    # Parenthesis around both section and substance
    elsif data
      rules = data[2].split('|').map{|e| "*#{data[1]}#{e}#{data[3]}"}
      filter.glue = "or" if rules.size > 1 
      rules.each do |rule|
        load_single_rule(rule,filter)
      end
    # There's a parenthesis somewhere else
    elsif data = line.match(/(.*)\((.*)\)(.*)/)
      load_single_rule(line,filter)
    else
      rules = line.split('|') 
      filter.glue = "or" if rules.size > 1
      rules.each_with_index do |rule,i|
        if i>0 
          load_single_rule("*#{rule}",filter)
        else
          load_single_rule(rule,filter)
        end
      end
    end
  end
  
  def load_single_rule(line,filter)
    data = line.match( 
      /^               #start, ENGLISH EXPRESSION
      \*               #first ch is a star
      \s?              #ev. space
      !?\s?            #ev. DeMorgan
      \^               #second is the start sign
      ([a-zA-Z(\-|)]+) #alphabeth & (-|) characters
      :?               #ev colon
      #\s*              #zero or more spaces
      (?:\\s\+)?       #ev. \s+ 
      (.+)             #the rest, the substance
      /x)
    data = line.match(
      /^                    #start, JAPANESE EXPRESSION
      \*                    #first ch is a star
      \s?                   #ev. space
      !?\s?                 #ev. DeMorgan
      (SUB|REC|SEN|CCC|TOC) #subject,recipient or sender
      \s\?\?\s              #space with question marks
      (.+)                  #substance
      /x) unless data
    raise RuleLoadException, "The line: '#{line}' doesn't match pattern" unless data
    substances = split_substance(data[2])
    filter.glue = "or" if substances.size > 1
    filter.glue = "or" if line.match(/^\*\s?!/)
    substances.each do |substance|
      rule           = Rule.new
      rule.section   = Rule.map_section(data[1])
      rule.substance = strip_substance(substance)
      rule.part      = load_part(substance)
      filter.rules << rule
    end
  end

  def split_substance(s)
    data = s.match(/(.*)\((.*)\)(.*)/)
    if data.nil?
      return s.split('|').map{|e| unescape_dots(e)}
    end
    return data[2].split('|').map{|e| unescape_dots("#{data[1]}#{e}#{data[3]}")}
  end

  def load_part(s)
    if s =~ /^\.\*/    #beginning star
      if s =~ /\.\*$/  #ending star
        Rule::CONTAINS 
      elsif s =~ /\$$/ #ending dollar
        Rule::ENDS_WITH
      else
        Rule::CONTAINS
      end
    elsif s =~ /^\^/   #beginning top
      s =~ /\$$/ ? Rule::IS : Rule::BEGINS_WITH  
    elsif s =~ /\.\*$/ #ending star 
      is_english?(s) ? Rule::BEGINS_WITH : Rule::CONTAINS
    elsif s =~ /\$$/   #ending dollar
      is_english?(s) ? Rule::IS : Rule::ENDS_WITH
    else
      is_english?(s) ? Rule::BEGINS_WITH : Rule::CONTAINS
    end
  end

  def is_english?(s); s.match(/^[\x00-\x7F]*$/) end

  def strip_substance(s)
    s = s[2..-1] if s =~ /^\.\*/ #beginning star
    s = s[0..-3] if s =~ /\.\*$/ #ending star
    s = s[0..-2] if s =~ /\$$/   #ending dollar
    s = s[1..-1] if s =~ /^\^/   #beginning hat
    s
  end

  def action?(line); folder_forwarding?(line) or mail_forwarding?(line) end
  def folder_forwarding?(line); line =~ /^\.(.*)\/$/ end 
  def mail_forwarding?(line); line =~ /^!/ end
  def load_action(recipe,line,filter)
    action             = Action.new
    line = line.strip
    if mail_forwarding?(line)
      if recipe.include?("c")
        action.operation = Action::FORWARD_COPY_TO
      else
        action.operation = Action::FORWARD_MESSAGE_TO
      end
    elsif folder_forwarding?(line)
      if recipe.include?("c")
        action.operation = Action::COPY_MESSAGE_TO
      else
        action.operation = Action::MOVE_MESSAGE_TO
      end 
    else
      raise FilterLoadException, "Destination folder or rule pattern: \"#{line}\" is not written correctly."
    end
    action.destination = Net::IMAP.decode_utf7(strip_destination(line))
    if action.forward_message? && !action.destination_resembles_email?
      raise InvalidEmailException, "Destination email must be valid." 
    end

    filter.actions << action
  end

  def strip_destination(s)
    s.gsub!(/\/$/,'')
    s.gsub!(/^\./,'')
    s.gsub!(/^!/,'')
#    data = s.match(/^!\s*(.*)/)
#    return data[1] if data
#    data = s.match(/^\.(.*)\//)
#    return data[1] if data
#    data = s.match(/(.+)\//)
#    return data[1] if data
#    data = s.match(/\.(.*)/)
#    return data[1] if data
    s.strip
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

  private

    def unescape_dots(s)
      raise RuleLoadException, "Found unescaped dots in \"#{s}\"." if s.match(/[^\\]\.[^*]/)
      s.gsub(/\\\./,'.')
    end
end
