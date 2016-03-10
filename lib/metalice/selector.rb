class Selector

  class << self
    def priority(reference, item, opt = {})
      return nil if reference.nil? || item.nil?
      opt = { prefix_word: "", split_word: "_" }.merge(opt)
      opt[:prefix_word] += opt[:split_word] if opt[:prefix_word].present?
      ref = reference.is_a?(String) ? reference.constantize : reference
      self.send("check_defined_for_#{ref.class.name.downcase}", ref, priority_list(item, opt))
    end

    # ===
    def priority_list(item, opt)
      if item.is_a?(Array)
        return item.map{ |z| opt[:prefix_word] + z } + opt_method_miss(opt)
      else
        item_list = item.is_a?(String) ? item.split(opt[:split_word]) : item
        return item_list.collect.with_index {|w, i| opt[:prefix_word] + item_list[0..i].join(opt[:split_word]) }.reverse + opt_method_miss(opt)
      end
    end

    def opt_method_miss(opt)
      method_miss = opt.fetch(:method_miss, nil)
      return [] if method_miss == false
      m = opt[:prefix_word] + opt[:split_word]
      m += method_miss.nil? ? "method_miss" : method_miss
      [m]
    end

    # ===
    def check_defined_for_module(ref, priority_list)
      priority_list.each do |m|
        return m if ref.method_defined?(m.to_sym)
      end
      nil
    end

    def check_defined_for_class(ref, priority_list)
      # TODO
    end

    def check_defined_for_hash(ref, priority_list)
      ref.symbolize_keys!
      priority_list.each do |m|
        return ref.fetch(m.to_sym) if ref.key?(m.to_sym)
      end
      nil
    end

    def check_defined_for_array(ref, priority_list)
      priority_list.each do |m|
        return m if ref.include?(m)
      end
      nil
    end
  end
end
