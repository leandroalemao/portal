module ApplicationHelper

  def labeled_form_for(object, options = {}, &block)
    options[:builder] = LabeledFormBuilder
    simple_form_for(object, options, &block)
  end

end
