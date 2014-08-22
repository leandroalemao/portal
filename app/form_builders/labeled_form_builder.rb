class LabeledFormBuilder < ActionView::Helpers::FormBuilder

  delegate :capture, :content_tag, :tag, to: :@template

  %w[text_field text_area password_field collection_select].each do |method_name|
    define_method(method_name) do |name, *args|
      errors = object.errors[name].any?? " error" : ""
      error_msg = object.errors[name].any?? content_tag(:span, object.errors[name].join(","), class: "help-inline") : ""
      options = args.extract_options!
      help_text =  !options[:help_text].blank? ? content_tag(:span,options[:help_text], class: "help-block") : "" 
      args.push(options)
      content_tag :div, class: "clearfix#{errors}" do
        field_label(name, options) + help_text + error_msg + content_tag(:div, class: "input#{errors}") do
          super(name, options)# + " " + error_msg
        end
      end
    end
  end

  def div(*args, &block)
    options = args.extract_options!
    data = block_given? ? capture(&block) : ''
    content_tag(:div, data, class: options[:class])
  end

  def check_box(name, *args)
    content_tag :div, class: "field" do
      super + " " + field_label(name, *args)
    end
  end

  def collection_check_boxes(attribute, records, record_id, record_name)
    content_tag :div, class: "field" do
      @template.hidden_field_tag("#{object_name}[#{attribute}][]") +
      records.map do |record|
        element_id = "#{object_name}_#{attribute}_#{record.send(record_id)}"
        checkbox = @template.check_box_tag("#{object_name}[#{attribute}][]", record.send(record_id),  object.send(attribute).include?(record.send(record_id)), id: element_id)
        checkbox + " " + @template.label_tag(element_id, record.send(record_name))
      end.join(tag(:br)).html_safe
    end
  end
  
  def submit(*args)
    content_tag :div, class: "actions" do
      super
    end
  end
  
  def error_messages
    if object.errors.full_messages.any?
      content_tag(:div, :class => "error_messages") do
        content_tag(:h4, "Campos Incorretos:") +
        content_tag(:ul) do
          object.errors.full_messages.map do |msg|
            content_tag(:li, msg)
          end.join.html_safe
        end
      end
    end
  end
  
private

  def field_label(name, *args)
    options = args.extract_options!
    required = object.class.validators_on(name).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
    label(name, options[:label], class: ("required" if required))
  end
  
  def objectify_options(options)
    super.except(:label)
  end
end
