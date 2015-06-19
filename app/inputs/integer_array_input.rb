class IntegerArrayInput < SimpleForm::Inputs::NumericInput
  def input
    input_html_options[:type] ||= input_type
    
    Array(object.public_send(attribute_name)).map do |array_el|
      @builder.number_field(nil, input_html_options.merge(value: array_el, name: "#{object_name}[#{attribute_name}][]"))
    end.join.html_safe
  end
  
  def input_type
    :integer
  end
end
