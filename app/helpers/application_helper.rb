module ApplicationHelper
  def admin_pages?; request.path =~ /translations/ || request.path =~ /locales/ end 
  def create(s); t2(:create,s) end
  def current_language; english? ? t(:japanese) : t(:english) end
  def edit(s); t2(:edit,s) end
  def edit_p(s); tp2(:edit,s) end
  def new(s); t2(:new,s) end
  def pl(s); t(s).match(/\w/) ? t(s).pluralize : t(s) end
  def title(title)
    content_for(:title){ title.to_s }
    raw "<h1>#{title}</h1>"
  end
  def sure?; t('messages.sure?') end
  def tp2(s1,s2); t(lbl(s1), :obj => pl(s2)) end
  def update(s); t2(:update,s) end
  def update_p(s); tp2(:update,s) end
  def verify(s); t2(:verify,s) end
  def view(s); tp2(:view,s) end
  def link_to_add_fields(name)
    fields = "<p>#{render('address_field', :no => 99, :value => '')}</p>"
    link_to_function(name, "add_fields(this, '#{escape_javascript(fields)}')", :class => "hidden active", :id => :add_address_field)
  end
end
