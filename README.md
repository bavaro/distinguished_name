#A String Representation of Distinguished Names

* This is a gem for interacting with the string representation of distinguished names, per the RFC-1779 (http://www.ietf.org/rfc/rfc1779.txt)

* It will allow you to transform a distinguished name that is passed from Apache in a particular format into another format.
```
DistinguishedName::Transform.slashify("CN=Welker.Wes.83,OU=people,OU=Patriots,O=NFL,C=US")
# => "/C=US/O=NFL/OU=Patriots/OU=people/CN=Welker.Wes.83"
DistinguishedName::Transform.ldapify("/C=US/O=NFL/OU=Patriots/OU=people/CN=Welker.Wes.83")
# => "CN=Welker.Wes.83,OU=people,OU=Patriots,O=NFL,C=US"
```

* It will also leave distinguished names 'unconverted', but still validate them
```
DistinguishedName::Transform.slashify("/C=US/O=NFL/OU=Patriots/OU=people/CN=Welker.Wes.83")
# => "/C=US/O=NFL/OU=Patriots/OU=people/CN=Welker.Wes.83"
DistinguishedName::Transform.ldapify("CN=Welker.Wes.83,OU=people,OU=Patriots,O=NFL,C=US")
# => "CN=Welker.Wes.83,OU=people,OU=Patriots,O=NFL,C=US"
```

* It will raise an OpenSSL::X509::NameError if you give it an invalid Distinguished Name

