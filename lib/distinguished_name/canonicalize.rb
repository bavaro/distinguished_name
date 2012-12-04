require File.join(File.dirname(__FILE__), '..', 'distinguished_name')

class DistinguishedName::Canonicalize

  class << self

    def reverse(dn, order=['CN','OU','O','C'])
      STDERR.puts "Warning!  DistinguishedName::Canonicalize is deprecated.  Use DistinguishedName::Transform instead."
      @dn = dn
      @order = []
      order.each {|o| @order << o + '='}
      @separators = [',', '/']
      return @dn if dn_contains_no_equals || dn_invalid?
      @separators.each do |s|
        @current_separator = s
        @dn_elements = @dn.split(s)
        clean_array
        possibly_join_elements
        break if number_of_elements_matches_given_number_of_equal_signs?
      end
      @order.reverse! if @current_separator == '/'
      reorder_dn
      rejoin_dn
      return @dn
    end

    def comma_separated_format(dn, order=['CN','OU','O','C'])
      return dn if dn.nil? || dn == ""
      return dn if in_comma_separated_format?(dn)
      reverse(dn, order)
    end

    def slash_separated_format(dn, order=['CN','OU','O','C'])
      return dn if dn.nil? || dn == ""
      return reverse(reverse(dn, order), order) if in_slash_separated_format?(dn)
      reverse(dn, order)
    end

    def rasify(dn)
      comma_separated_format(dn)
    end

    def apachify(dn)
      slash_separated_format(dn)
    end

    def in_comma_separated_format?(dn)
      return false if dn_does_not_contain_separator(',', dn)
      (((dn.scan('=')).size - (dn.scan('\=')).size) == ((dn.scan(',')).size - (dn.scan('\,')).size) + 1)
    end

    def in_slash_separated_format?(dn)
      return false if dn_does_not_contain_separator('/', dn)
      (((dn.scan('=')).size - (dn.scan('\=')).size) == ((dn.scan('/')).size - (dn.scan('\/')).size))
    end

  private

    def rejoin_dn
      if @current_separator == ',' 
        @dn = '/' + @dn_elements.join('/')
      else
        @dn = @dn_elements.join(',')
      end
    end

    def reorder_dn
      tmp_dn_elements = []
      @order.each do |o|
        @dn_elements.each {|e| (tmp_dn_elements << e) if e.downcase.match("^#{o.downcase}")}
      end
      @dn_elements = tmp_dn_elements.reverse!
    end

    def possibly_join_elements
      @dn_elements.each_with_index do |element, index|
        if number_of_unescaped_equal_signs(element) == 0
          join_with_prev(index)
        end
      end
    end

    def join_with_prev(index)
      curr = @dn_elements[index]
      prev = @dn_elements[index - 1]
      new_element = [prev, curr].join(@current_separator)
      @dn_elements[index - 1] = new_element
      @dn_elements.delete_at(index)
    end

    def clean_array
      @dn_elements.delete_if{ |d| d.nil? || d =="" }
    end

    def dn_does_not_contain_separator(separator, dn)
      !((dn.scan(separator).size - dn.scan("\\#{separator}").size) > 0)
    end
    
    def number_of_elements_matches_given_number_of_equal_signs?
      count = 0
      @dn_elements.each do |element|
        count += number_of_unescaped_equal_signs(element)
        element.strip!
      end
      count == @dn_elements.size
    end

    def dn_contains_no_equals
      @dn.count('=') == 0
    end

    def dn_invalid?
      count = 0
      dn_downcase = @dn.downcase
      @order.each do |o|
        curr = dn_downcase.scan(o.downcase)
        if !(curr.nil? || curr == "")
          case curr[0]
            when "c="
              count += 1
            when "cn="
              count += 1
          end
        end
      end
      count != 2
    end

    def number_of_unescaped_equal_signs(element)
      n = 1
      num_esc_equals = 0
      num_equals = element.count('=')
      while (element.index('\=', n))
        num_esc_equals += 1
        n = element.index('\=', n)
        n += 2
      end
      return (num_equals - num_esc_equals)
    end

  end

end
