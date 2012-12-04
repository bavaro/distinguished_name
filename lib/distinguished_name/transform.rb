require 'openssl'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'distinguished_name'))

class DistinguishedName::Transform

  class << self

    def slashify(dn_string)
      x509_parsed_dn = parse_dn(dn_string)
      prefix = '/'
      separator = ''
      if in_slash_format?(dn_string)
        big_endian(x509_parsed_dn, prefix, separator)
      else
        little_endian(x509_parsed_dn, prefix, separator)
      end
    end

    def ldapify(dn_string)
      x509_parsed_dn = parse_dn(dn_string)
      prefix = ''
      separator = ','
      if in_ldap_format?(dn_string)
        big_endian(x509_parsed_dn, prefix, separator)
      else
        little_endian(x509_parsed_dn, prefix, separator)
      end
    end

private 

    def big_endian(x509_parsed_dn, prefix, separator)
      x509_parsed_dn.to_a.map {|piece| "#{prefix}#{piece[0]}=#{piece[1]}" }.join(separator)
    end

    def little_endian(x509_parsed_dn, prefix, separator)
      x509_parsed_dn.to_a.map {|piece| "#{prefix}#{piece[0]}=#{piece[1]}" }.reverse.join(separator)
    end

    def in_slash_format?(dn_string)
      !in_ldap_format?(dn_string)
    end

    def in_ldap_format?(dn_string)
      begin
        OpenSSL::X509::Name.parse_rfc2253(dn_string)
      rescue OpenSSL::X509::NameError
        return false
      end
      return true
    end
    
    def parse_dn(dn_string)
      begin 
        OpenSSL::X509::Name.parse(dn_string)
      rescue parse_exception
        raise OpenSSL::X509::NameError
      end
    end

    def parse_exception
      if defined?(JRUBY_VERSION) 
        JRUBY_VERSION >= "1.7.1" ? TypeError : Java::JavaLang::NullPointerException  
      else
        TypeError
      end
    end

  end
end
