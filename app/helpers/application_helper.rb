module ApplicationHelper
  def present(model)
    klass = "#{model.class}Presenter".constantize
    klass.new(model)
  end
end
