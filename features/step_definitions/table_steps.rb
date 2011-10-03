Then /^I should see the following (\w+):$/ do |mdl,tbl|
  tbl.diff! tableish("div.table##{mdl} div.outer div.inner", 'span')
end

def table_row(tbl=nil,order)
  if tbl.nil?
    "div.table div.outer div.inner:nth-child(#{digit order})"
  else
    "div.table##{tbl} div.outer div.inner:nth-child(#{digit order})"
  end
end
