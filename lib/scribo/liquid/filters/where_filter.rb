module WhereFilter
  # Filter an array of objects
  #
  # input    - the object array.
  # property - the property within each object to filter by.
  # value    - the desired value.
  #            Cannot be an instance of Array nor Hash since calling #to_s on them returns
  #            their `#inspect` string object.
  #
  # Returns the filtered array of objects
  def where(input, property, value)
    return input if !property || value.is_a?(Array) || value.is_a?(Hash)
    return input unless input.respond_to?(:select)

    input    = input.values if input.is_a?(Hash)
    input_id = input.hash

    # implement a hash based on method parameters to cache the end-result
    # for given parameters.
    @where_filter_cache ||= {}
    @where_filter_cache[input_id] ||= {}
    @where_filter_cache[input_id][property] ||= {}

    # stash or retrive results to return
    @where_filter_cache[input_id][property][value] ||= begin
      input.select do |object|
        compare_property_vs_target(item_property(object, property), value)
      end.to_a
    end
  end

  # `where` filter helper
  #
  def compare_property_vs_target(property, target)
    case target
    when NilClass
      return true if property.nil?
    when Liquid::Expression::MethodLiteral # `empty` or `blank`
      target = target.to_s
      return true if property == target || Array(property).join == target
    else
      target = target.to_s
      if property.is_a? String
        return true if property == target
      else
        Array(property).each do |prop|
          return true if prop.to_s == target
        end
      end
    end

    false
  end

  def item_property(item, property)
    # Jekyll uses :site here, but we use strings?
    @item_property_cache ||= @context.registers['site'].filter_cache[:item_property] ||= {}
    @item_property_cache[property] ||= {}
    @item_property_cache[property][item] ||= begin
      property = property.to_s
      property = if item.respond_to?(:to_liquid)
                   read_liquid_attribute(item.to_liquid, property)
                 elsif item.respond_to?(:data)
                   item.data[property]
                 else
                   item[property]
                 end

      parse_sort_input(property)
    end
  end

  def read_liquid_attribute(liquid_data, property)
    return liquid_data[property] unless property.include?('.')

    property.split('.').reduce(liquid_data) do |data, key|
      data.respond_to?(:[]) && data[key]
    end
  end

  FLOAT_LIKE   = /\A\s*-?(?:\d+\.?\d*|\.\d+)\s*\Z/.freeze
  INTEGER_LIKE = /\A\s*-?\d+\s*\Z/.freeze
  private_constant :FLOAT_LIKE, :INTEGER_LIKE

  # return numeric values as numbers for proper sorting
  def parse_sort_input(property)
    stringified = property.to_s
    return property.to_i if INTEGER_LIKE.match?(stringified)
    return property.to_f if FLOAT_LIKE.match?(stringified)

    property
  end
end

Liquid::Template.register_filter(WhereFilter)
