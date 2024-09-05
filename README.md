# Utilities

## sign_eum_csr_variant_O.sh / Generate CSR for a variant O EUM CA certificate 

First it is required to create the private key in the HSM. This is outside the scope of this document. 

Then it is required to install the OpenSSL engine for PKCS#11 modules (https://github.com/OpenSC/libp11).

The availability of the engine can be verified like this:

```
$ openssl engine -t pkcs11
(pkcs11) pkcs11 engine
     [ available ]
```

Then, the CSR can be generated with a command like the following:

* The DN must contain at least the organizationName attribute (O) and the commonName attribute (CN).
* The DN attributes should be set in the order presented in https://cabforum.org/working-groups/server/baseline-requirements/requirements/#7142-subject-attribute-encoding
* It is a good idea to use a different EUM CA for different eUICC models or production batches, so a number at the end of the commonName is currently recommended. See SGP.22 v3.1, "2.7 Certificate Revocation".

```
$ ./sign_eum_csr_variant_O.sh
Usage: ./sign_eum_csr_variant_O.sh <pkcs11_module> <key_id> <requested_dn> <eum_oid> <euicc_allowed_organization> <eum_iin>
$ ./sign_eum_csr_variant_O.sh /usr/lib/x86_64-linux-gnu/pkcs11/yubihsm_pkcs11.so 0:9877 "O=Contoso,CN=Contoso EUM 1" 1.3.6.1.4.1.100000 Contoso 89049032
```
