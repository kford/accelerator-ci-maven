#!/bin/bash

echo "PUBLISH: Developer Portal Documentation"
echo "Jenkins Workspace: $WORKSPACE"
echo "PWD: $PWD"
curContext=$(find . -type d)
echo "########################################"
echo "########################################"
echo "########################################"
echo "########################################"
echo "CURRENT CONTEXT: $curContext"
echo "########################################"
echo "########################################"
echo "########################################"
echo "########################################"


# GET AN ACCESS TOKEN
export ACCESS_TOKEN=$(curl -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" \
  -H "Accept: application/json;charset=utf-8" \
  -H "Authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" \
  -X POST https://login.e2e.apigee.net/oauth/token \
  -d 'username=kevinford@google.com&password=!n0r1t5@C&grant_type=password' | awk -F'"' '{print $4}')
echo "Access Token is: $ACCESS_TOKEN"


# GET ETAG FOR BAGGAGE SPEC
export ETAG_BAGGAGE=$(curl -i -X GET "https://e2e.apigee.net/c3Rvc-ZG9j-1822" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: kevinford-eval" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo "Baggage ETag is: $ETAG_BAGGAGE"

# GET ETAG FOR FLIGHTS SPEC
export ETAG_FLIGHTS=$(curl -i -X GET "https://e2e.apigee.net/c3Rvc-ZG9j-1823" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: kevinford-eval" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo "Flights ETag is: $ETAG_FLIGHTS"


# UPDATE THE BAGGAGE SPEC
curl -i -X PUT "https://e2e.apigee.net/c3Rvc-ZG9j-1822/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $ETAG_BAGGAGE" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/baggage-spec.json

# UPDATE THE FLIGHTS SPEC
curl -i -X PUT "https://e2e.apigee.net/c3Rvc-ZG9j-1823/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $ETAG_FLIGHTS" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/flights-spec.json


# PUBLISH THE BAGGAGE SPEC
curl -i -X POST "https://e2e.apigee.net/portals/api/sites/kevinford-eval-boeing/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d '{
      "title": "Baggage API",
      "description": "Access baggage details, logistics, and tracking.",
      "edgeAPIProductName": "helloworld",
      "imageUrl":"/files/baggage-icon.png",
      "visibility": true,
      "anonAllowed": true,
      "specId": "baggage-spec",
      "specContent": "/c3Rvc-ZG9j-1817/content",
      "orgname": "kevinford-eval"
   }'
