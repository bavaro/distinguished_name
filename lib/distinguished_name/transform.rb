require 'openssl'

class DistinguishedName::Transform

  class << self

    def slashify(dn_string)
      x509_parsed_dn = parse_dn(dn_string)
      x509_parsed_dn.to_a.map {|piece| "/#{piece[0]}=#{piece[1]}" }.reverse.join
    end

    def ldapify(dn_string)
      x509_parsed_dn = parse_dn(dn_string)
      x509_parsed_dn.to_a.map {|piece| "#{piece[0]}=#{piece[1]}" }.reverse.join(",")
    end

private 
    
    def parse_dn(dn_string)
      begin 
        OpenSSL::X509::Name.parse(dn_string)
      rescue Java::JavaLang::NullPointerException #MRI can throw a TypeError
        raise OpenSSL::X509::NameError
      end
    end

  end

end
