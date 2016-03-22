# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def javascript(*args)
    args = args.map { |arg| arg == :defaults ? arg : arg.to_s }
    content_for(:head) { javascript_include_tag(*args) }
  end
  
  def remove_link_unless_new_record(fields, label = "remove")
    out = ''
    out << fields.hidden_field(:_delete)  unless fields.object.new_record?
    out << link_to(label, "##{fields.object.class.name.underscore}", :class => 'remove')
    out
  end

  # This method demonstrates the use of the :child_index option to render a
  # form partial for, for instance, client side addition of new nested
  # records.
  #
  # This specific example creates a link which uses javascript to add a new
  # form partial to the DOM.
  #
  #   <% form_for @project do |project_form| -%>
  #     <div id="tasks">
  #       <% project_form.fields_for :tasks do |task_form| %>
  #         <%= render :partial => 'task', :locals => { :f => task_form } %>
  #       <% end %>
  #     </div>
  #   <% end -%>
  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f  

    s = ""
    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      s = render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
    return s
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end

  def golo_link_to(text, url, options = {})
    link_to "#{text} >>", url, options
  end

  def commafy(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)(?!\d*\.)/, "\\1,").reverse
  end

  # Request from an iPhone or iPod touch? (Mobile Safari user agent)
  def mobile_user_agent?
    request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  end
end
