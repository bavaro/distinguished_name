require File.join(File.dirname(__FILE__), 'test_helper')

class TransformTest < Test::Unit::TestCase


  def setup
    @ldap_dn  = "CN=Welker.Wes.83,OU=people,OU=Patriots,O=NFL,C=US"
    @slash_dn = "/C=US/O=NFL/OU=Patriots/OU=people/CN=Welker.Wes.83"
    super
  end

  def test_ldapify_doesnt_modify_ldap_dn
    assert_equal(@ldap_dn, DistinguishedName::Transform.ldapify(@ldap_dn))
  end

  def test_slashify_doesnt_modify_slash_dn
    assert_equal(@slash_dn, DistinguishedName::Transform.slashify(@slash_dn))
  end

  def test_slashify_accepts_a_comma_separated_version_and_returns_a_slash_separated_version_of_the_dn
    assert_equal(@slash_dn, DistinguishedName::Transform.slashify(@ldap_dn))
  end

  def test_ldapify_accepts_a_slash_separated_version_and_returns_a_comma_separated_version_of_the_dn
    assert_equal(@ldap_dn, DistinguishedName::Transform.ldapify(@slash_dn))
  end

  def test_slashify_method_fails_gracefully_with_invalid_dn_string_that_has_no_equal_sign
    bad_dn = 'foo'
    assert_raise OpenSSL::X509::NameError do
      DistinguishedName::Transform.slashify(bad_dn)
    end
  end

  def test_dn_parsing_raises_when_there_is_an_invalid_keyword
    bad_dn = 'INVALID_KEYWORD=YoMama'
    assert_raise OpenSSL::X509::NameError do
      DistinguishedName::Transform.ldapify(bad_dn)
    end
  end

  def test_ldapify_method_fails_gracefully_with_invalid_dn_string_that_has_no_equal_sign
    bad_dn = 'foo'
    assert_raise OpenSSL::X509::NameError do
      DistinguishedName::Transform.ldapify(bad_dn)
    end
  end

  def test_arbitrarily_ordered_keywords_slashifies_correctly
    arbitrary_comma_dn = "ST=New Jersey,L=What is L,OU=Organizational Units,OU=Oklahoma University,CN=Ja Rule,C=CAN"
    expected_dn = "/C=CAN/CN=Ja Rule/OU=Oklahoma University/OU=Organizational Units/L=What is L/ST=New Jersey"
    assert_equal(expected_dn, DistinguishedName::Transform.slashify(arbitrary_comma_dn))
  end

  def test_arbitrarily_ordered_keywords_ldapifies_correctly
    arbitrary_slash_dn = "/C=CAN/CN=Ja Rule/OU=Oklahoma University/OU=Organizational Units/L=What is L/ST=New Jersey"
    expected_dn = "ST=New Jersey,L=What is L,OU=Organizational Units,OU=Oklahoma University,CN=Ja Rule,C=CAN"
    assert_equal(expected_dn, DistinguishedName::Transform.ldapify(arbitrary_slash_dn))
  end
end
