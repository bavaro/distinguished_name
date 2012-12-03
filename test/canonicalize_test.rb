require 'test/test_helper'

class CanonicalizeTest < Test::Unit::TestCase

  def test_reversing_a_dn_string_with_slashes_happy_path
    dn = '/C=US/O=company_name/OU=developers/CN=John Smith'
    assert_equal 'CN=John Smith,OU=developers,O=company_name,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_putting_a_dn_string_with_slashes_in_comma_separated_format_happy_path
    dn = '/C=US/O=company_name/OU=developers/CN=John Smith'
    assert_equal 'CN=John Smith,OU=developers,O=company_name,C=US', DistinguishedName::Canonicalize.comma_separated_format(dn)
  end

  def test_reversing_a_dn_string_with_commas_happy_path
    dn = 'CN=John Smith,OU=developers,O=company_name,C=US'
    assert_equal '/C=US/O=company_name/OU=developers/CN=John Smith', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_putting_a_dn_string_with_commas_in_slash_separated_format_happy_path
    dn = 'CN=John Smith,OU=developers,O=company_name,C=US'
    assert_equal '/C=US/O=company_name/OU=developers/CN=John Smith', DistinguishedName::Canonicalize.slash_separated_format(dn)
  end

  def test_reversing_a_dn_string_with_non_default_keys_returns_that_string_unaltered
    dn_with_nonstandard_keys = 'X=person,Y=place,Z=thing'
    assert_equal dn_with_nonstandard_keys, DistinguishedName::Canonicalize.reverse(dn_with_nonstandard_keys)
  end

  def test_reversing_a_dn_string_with_no_equal_signs_just_returns_that_string_unaltered
    dn = '/hi/there/how/are/you?'
    assert_equal dn, DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_reversing_a_dn_string_with_escaped_equal_signs_returns_that_string_unaltered
    dn = 'CN\=foo,OU\=bar,O\=baz,C\=US'
    assert_equal dn, DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_reversing_a_dn_string_with_unescaped_comma_returns_that_string_unaltered
    dn = "CN=boo,OU=foo,choo,voo,O=bar,C=beeeergood"
    assert_equal dn, DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_reversing_a_dn_string_with_only_commas_just_returns_that_string_unaltered
    dn = 'hi,there,how,are,you?'
    assert_equal dn, DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_reversing_a_dn_string_with_empty_slashes_ignores_those_empty_elements
    assert_equal 'CN=b,C=a', DistinguishedName::Canonicalize.reverse('/C=a////CN=b')
  end

  def test_reversing_a_dn_string_with_empty_commas_ignores_those_empty_elements
    assert_equal '/C=b/CN=a', DistinguishedName::Canonicalize.reverse('CN=a,,,,C=b')
  end

  def test_reversing_a_dn_string_with_two_CNs_and_no_Cs_returns_that_string_unaltered_per_the_default_format
    dn = 'CN=John Smith,OU=developers,O=company_name,CN=US'
    assert_equal dn, DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_dn_reversing_strips_spaces
    dn = 'CN=blah, OU=foo, C=bar'
    assert_equal '/C=bar/OU=foo/CN=blah', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_slashed_dn_with_escaped_comma_can_be_reversed
    dn = '/CN=John Smith\, jr./C=US/OU=developers/O=company_name'
    assert_equal 'CN=John Smith\, jr.,OU=developers,O=company_name,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_slashed_dn_with_escaped_slash_can_be_reversed
    dn = '/C=US/O=company_name/OU=developers\/testers/CN=John Smith'
    assert_equal 'CN=John Smith,OU=developers\/testers,O=company_name,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_slashed_dn_with_escaped_end_comma_can_be_reversed
    dn = '/C=US/O=company_name\, inc./OU=developers/CN=John Smith'
    assert_equal 'CN=John Smith,OU=developers,O=company_name\, inc.,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_comma_dn_with_escaped_comma_can_be_reversed
    dn = 'CN=John Smith\, jr.,OU=developers,O=company_name,C=US'
    assert_equal '/C=US/O=company_name/OU=developers/CN=John Smith\, jr.', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_comma_dn_with_escaped_slash_can_be_reversed
    dn = 'CN=John Smith,OU=developers\/testers,O=company_name,C=US'
    assert_equal '/C=US/O=company_name/OU=developers\/testers/CN=John Smith', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_multiple_ou_dn_canonicalized_for_comma_dn
    dn = '/C=US/O=company_name/OU=asdf/OU=blerg/OU=developers/CN=John Smith'
    assert_equal 'CN=John Smith,OU=developers,OU=blerg,OU=asdf,O=company_name,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_removal_of_extra_fields_not_in_order_with_slashy
    dn = '/C=US/O=company_name/OU=asdf/OU=blerg/OU=developers/CN=John Smith/FOO=bar'
    assert_equal 'CN=John Smith,OU=developers,OU=blerg,OU=asdf,O=company_name,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_removal_of_extra_fields_not_in_order_with_commas
    dn = 'FOO=bar,CN=John Smith,CNOODLE=yum,FII=fofum,OU=asdf,OU=blerg,OU=developers,O=company_name,C=US'
    assert_equal '/C=US/O=company_name/OU=developers/OU=blerg/OU=asdf/CN=John Smith', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_multiple_ou_dn_canonicalized_with_comma
    dn = 'CN=John Smith,OU=asdf,OU=blerg,OU=developers,O=company_name,C=US'
    assert_equal '/C=US/O=company_name/OU=developers/OU=blerg/OU=asdf/CN=John Smith', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_escaped_equals_in_dn_can_be_reversed
    dn = '/C=US/O=company_name/OU=asdf/CN=login\=John Smith'
    assert_equal 'CN=login\=John Smith,OU=asdf,O=company_name,C=US', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_escaped_equals_in_dn_is_reverse_canonicalized
    dn = 'CN=login\=John Smith,C=US,OU=asdf,O=company_name'
    assert_equal '/C=US/O=company_name/OU=asdf/CN=login\=John Smith', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_reversing_a_slash_separated_dn_orders_dn_appropriately_with_non_default_order
    dn = '/C=US/O=Test/OU=abc/CN=xyz'
    assert_equal 'O=Test,OU=abc,C=US,CN=xyz', DistinguishedName::Canonicalize.reverse(dn, ['O', 'OU', 'C', 'CN'])
  end

  def test_reversing_a_comma_separated_dn_orders_dn_appropriately_with_non_default_order
    dn = 'O=Test,OU=abc,C=US,CN=xyz'
    assert_equal '/CN=xyz/C=US/OU=abc/O=Test', DistinguishedName::Canonicalize.reverse(dn, ['O', 'OU', 'C', 'CN'])
  end

  def test_comma_separated_format_with_a_comma_separated_style_dn
    dn = 'CN=david,OU=abc,O=Beckham,C=US'
    assert_equal 'CN=david,OU=abc,O=Beckham,C=US', DistinguishedName::Canonicalize.comma_separated_format(dn) 
  end
  
  def test_slash_separated_format_with_a_comma_separated_style_dn
    dn = 'CN=david,OU=abc,O=Beckham,C=US'
    assert_equal '/C=US/O=Beckham/OU=abc/CN=david', DistinguishedName::Canonicalize.slash_separated_format(dn) 
  end
  
  def test_comma_separated_format_with_a_slash_separated_style_dn
    dn = '/C=US/O=Beckham/OU=abc/CN=david'
    assert_equal 'CN=david,OU=abc,O=Beckham,C=US', DistinguishedName::Canonicalize.comma_separated_format(dn) 
  end
  
  def test_slash_separated_format_with_a_slash_separated_style_dn
    dn = '/C=US/O=Beckham/OU=abc/CN=david'
    assert_equal '/C=US/O=Beckham/OU=abc/CN=david', DistinguishedName::Canonicalize.slash_separated_format(dn) 
  end

  def test_comma_separated_format_with_a_comma_separated_style_dn_lowercase
    dn = 'cn=david,ou=abc,o=Beckham,c=US'
    assert_equal 'cn=david,ou=abc,o=Beckham,c=US', DistinguishedName::Canonicalize.comma_separated_format(dn) 
  end
  
  def test_slash_separated_format_with_a_comma_separated_style_dn_lowercase
    dn = 'cn=david,ou=abc,o=Beckham,c=US'
    assert_equal '/c=US/o=Beckham/ou=abc/cn=david', DistinguishedName::Canonicalize.slash_separated_format(dn) 
  end
  
  def test_comma_separated_format_with_a_slash_separated_style_dn_lowercase
    dn = '/c=US/o=Beckham/ou=abc/cn=david'
    assert_equal 'cn=david,ou=abc,o=Beckham,c=US', DistinguishedName::Canonicalize.comma_separated_format(dn) 
  end
  
  def test_slash_separated_format_with_a_slash_separated_style_dn_lowercase
    dn = '/c=US/o=Beckham/ou=abc/cn=david'
    assert_equal '/c=US/o=Beckham/ou=abc/cn=david', DistinguishedName::Canonicalize.slash_separated_format(dn) 
  end

  def test_in_comma_separated_format_returns_true_if_its_given_a_comma_separated_dn
    dn = 'CN=david,OU=abc,O=Beckham,C=US'
    assert DistinguishedName::Canonicalize.in_comma_separated_format?(dn) 
  end
  
  def test_in_comma_separated_format_returns_false_if_its_given_a_slash_separated_style_dn
    dn = '/C=US/O=Beckham/OU=abc/CN=david'
    assert !DistinguishedName::Canonicalize.in_comma_separated_format?(dn) 
  end

  def test_slash_separated_style_format_with_extra_field_ST_gets_stripped_after_reversing
    dn = '/C=US/ST=NJ/O=My Company, L.L.C./OU=QA/CN=John Smith'
    comma_dn = 'CN=John Smith,OU=QA,O=My Company, L.L.C.,C=US'
    assert_equal comma_dn, DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_in_comma_separated_format_must_contain_at_least_one_unescaped_comma_or_else_its_not_in_comma_separated_format
    assert_equal false, DistinguishedName::Canonicalize.in_comma_separated_format?('/C=US/ST=NJ/O=My Company, L.L.C./OU=QA/CN=John Smith')
  end

  def test_in_slash_separated_format_must_contain_at_least_one_unescaped_slash_or_else_its_not_in_slash_separated_format
    assert_equal false, DistinguishedName::Canonicalize.in_slash_separated_format?('CN=John Smith,OU=QA,O=My Company, L.L.C.,C=US')
  end

  def test_long_dn_sent_from_browser_is_properly_reversed
    sent_from_browser = '/C=US/ST=NJ/O=My Company, L.L.C./OU=QA/CN=John Smith'
    in_db = '/C=US/O=My Company, L.L.C./OU=QA/CN=John Smith'
    assert_equal in_db, DistinguishedName::Canonicalize.slash_separated_format(sent_from_browser)
  end

  def test_dn_with_less_than_sign_gets_reversed_properly
    dn = 'CN=lt\<lt,OU=Q\<A,O=My Company, L.L.C.,C=US'
    assert_equal '/C=US/O=My Company, L.L.C./OU=Q\<A/CN=lt\<lt', DistinguishedName::Canonicalize.reverse(dn)
  end

  def test_a_strange_dn_string_does_not_cause_problems
    dn = "CN=escapes \~\`\!\@\$\%\^\*\(\)\-\_\{\}\[\]\|\.\?, OU=A\~\`\!\@\$\%\^\*\(\)\-\_\{\}\[\]\|\.\?A, O=My Company, L.L.C., ST=NJ, C=US"
    assert_equal "/C=US/O=My Company, L.L.C./OU=A~`!@$%^*()-_{}[]|.?A/CN=escapes ~`!@$%^*()-_{}[]|.?", DistinguishedName::Canonicalize.reverse(dn)
  end


end
