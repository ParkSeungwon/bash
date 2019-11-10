premaster_secret=000400000000000431323334

# client random from Client Hello
echo -en '\x1D\xB7\xFD\x80\x15\x8D\x97\xDC\x6F\xF4\x8B\xA0\x64\x36\x02\x7B\x11\x19\x57\x64\xE6\xB0\x52\xC3\x49\x2A\x2A\x90\xC3\xF1\xAF\x40' >  /tmp/c_rand

# server random from Server Hello
echo -en '\x56\x10\x18\x22\x47\xF6\xFD\x19\xF3\xF0\xC8\xB7\xE3\x3E\xD7\xEE\x81\xCA\xFA\x9C\xFA\x78\x7A\xD5\x0B\x3E\x3A\x63\xD7\x34\x30\xBE' > /tmp/s_rand

# label
echo -en 'master secret' > /tmp/seed

## Master Key generation ##

# seed
cat /tmp/c_rand /tmp/s_rand >> /tmp/seed

# set a0 (=seed)
cat /tmp/seed > /tmp/a0

# a(n) = hmac( secret, a(n-1) )
cat /tmp/a0 | openssl dgst -sha256 -mac HMAC -macopt hexkey:$premaster_secret -binary > /tmp/a1
cat /tmp/a1 | openssl dgst -sha256 -mac HMAC -macopt hexkey:$premaster_secret -binary > /tmp/a2

# p(n) is hmac-sha256( secret, a(n)+seed)
cat /tmp/a1 /tmp/seed | openssl dgst -sha256 -mac HMAC -macopt hexkey:$premaster_secret -binary > /tmp/r1
cat /tmp/a2 /tmp/seed | openssl dgst -sha256 -mac HMAC -macopt hexkey:$premaster_secret -binary > /tmp/r2

# concatenation of the results to create the MasterSecret (48 bytes)
cat /tmp/r1 /tmp/r2 | head -c 48 > /tmp/mastersecret

echo 'master secret:' $(hexdump -ve '/1 "%02x"' /tmp/mastersecret)

## Key block generation ##

# set the masterkey as the new secret
secret=$(hexdump -ve '/1 "%02x"' /tmp/mastersecret)

# label
echo -en 'key expansion' > /tmp/seed

# seed
cat /tmp/s_rand /tmp/c_rand >> /tmp/seed

# a0 (=seed)
cat /tmp/seed > /tmp/a0

# a(n) = hmac( secret, a(n-1) )
cat /tmp/a0 | openssl dgst -sha256 -mac HMAC -macopt hexkey:$secret -binary > /tmp/a1
cat /tmp/a1 | openssl dgst -sha256 -mac HMAC -macopt hexkey:$secret -binary > /tmp/a2

# p(n) = hmac( secret, a(n)+seed )
cat /tmp/a1 /tmp/seed | openssl dgst -sha256 -mac HMAC -macopt hexkey:$secret -binary > /tmp/r1
cat /tmp/a2 /tmp/seed | openssl dgst -sha256 -mac HMAC -macopt hexkey:$secret -binary > /tmp/r2

# concatenation of the results
cat /tmp/r1 /tmp/r2 > /tmp/result

echo 'key_block:' $(hexdump -ve '/1 "%02x"' /tmp/result)
