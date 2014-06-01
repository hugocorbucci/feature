# encoding: UTF-8
module ActiveRecord::Associations::ClassMethods
  def has_many_with_toggle(relation_name, options = {}, &extension)
    toggled_association(:has_many, relation_name, options, extension)
  end
  alias_method_chain :has_many, :toggle

  def has_one_with_toggle(relation_name, options = {}, &extension)
    toggled_association(:has_one, relation_name, options, extension)
  end
  alias_method_chain :has_one, :toggle

  def belongs_to_with_toggle(relation_name, options = {}, &extension)
    toggled_association(:belongs_to, relation_name, options, extension)
  end
  alias_method_chain :belongs_to, :toggle

  def has_and_belongs_to_many_with_toggle(relation_name, options = {}, &extension)
    toggled_association(:has_and_belongs_to_many, relation_name, options, extension)
  end
  alias_method_chain :has_and_belongs_to_many, :toggle

  private

  def toggled_association(association, relation_name, options, extension)
    toggle_data = options.delete(:toggle)
    if toggle_data
      create_conditional_associations(association, relation_name, options, extension, toggle_data)
    else
      send("#{association}_without_toggle", relation_name, options, &extension)
    end
  end

  def create_conditional_associations(association, relation_name, base_options, extension, toggle_data)
    toggle_name = toggle_data[:name]
    class_name = relation_name.to_s.singularize
    options = {:class_name => class_name.classify}.merge(base_options)

    send(association, "#{relation_name}_with_#{toggle_name}", options.merge(toggle_data[:on]), &extension)
    send(association, "#{relation_name}_without_#{toggle_name}", options.merge(toggle_data[:off]), &extension)

    method_compositions = instance_methods.grep(/^#{relation_name}_with_#{toggle_name}/).map do |method|
      method.to_s.split("_with_#{toggle_name}")
    end
    create_original_association_methods(association, method_compositions, toggle_name, relation_name, options, extension)
  end

  def create_original_association_methods(macro, method_compositions, toggle_name, relation_name, options, extension)
    method_compositions.each do |method_composition|
      method_prefix, method_suffix = method_composition
      define_method "#{method_prefix}#{method_suffix}" do |*args|
        if Feature.active?(toggle_name.to_sym)
          self.send("#{method_prefix}_with_#{toggle_name}#{method_suffix}", *args)
        else
          self.send("#{method_prefix}_without_#{toggle_name}#{method_suffix}", *args)
        end
      end
    end
  end
end
