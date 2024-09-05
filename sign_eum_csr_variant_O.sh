#!/bin/bash

if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <pkcs11_module> <key_id> <requested_dn> <eum_oid> <euicc_allowed_organization> <eum_iin>"
    exit 1
fi

pkcs11_module=$1
key_id=$2
requested_dn=$3
eum_oid=$4
euicc_allowed_organization=$5
eum_iin=$6

if [[ ! "$eum_oid" =~ ^1\.3\.6\.1\.4\.1\..* ]]; then
    # TODO confirm with GSMA before removing this check.
    echo "Error: The EUM OID might require to begin with 1.3.6.1.4.1 according to SGP.22 v3.1, \"Annex E List of Identifiers (Informative)\", \"EUM Identifiers\"."
    exit 1
fi

if [[ ! "$eum_iin" =~ ^[0-9]{8}$ ]]; then
    echo "Error: The EUM IIN must be exactly 8 digits long."
    exit 1
fi

# TODO validate that at least the organization and commonName are provided in the requested DN. See SGP.22 v3.1, "4.5.2.1.0.3 EUM"

requested_dn=$(echo "$requested_dn" | tr ',' '\n')

openssl_config=$(mktemp /tmp/openssl.cnf.XXXXXX)
cat > "$openssl_config" <<EOF
openssl_conf = openssl_init

[openssl_init]
engines=engine_section

[engine_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11
MODULE_PATH = $pkcs11_module

[req]
prompt = no
distinguished_name = dn-name
req_extensions = req_exts

[dn-name]
$requested_dn

[ req_exts ]
# id-rspRole-eum-v2 (variant O)
certificatePolicies = critical,2.23.146.1.2.1.2
subjectAltName = RID:$eum_oid
# TODO support multiple 'organization' / 'IIN' value pairs as supported by SGP22 v2.5, "4.5.2.1.0.3 EUM"
nameConstraints = critical,permitted;dirName:dir_sect

[dir_sect]
O = $euicc_allowed_organization
serialNumber = $eum_iin
EOF

openssl req -new -engine pkcs11 -keyform engine -key "$key_id" -config "$openssl_config" -text

rm "$openssl_config"
