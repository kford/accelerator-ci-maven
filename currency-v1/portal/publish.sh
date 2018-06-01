#!/bin/bash

echo "PUBLISH: Developer Portal Documentation"
echo "Jenkins Workspace: $WORKSPACE"
echo "PWD: $PWD"
curContext=$(ls -l)
echo "CURRENT CONTEXT (Directories): $curContext"

export DEV_PORTAL_SITE=kevinford-eval-wells;
export BAGGAGE_SPEC_ID=c3Rvc-ZG9j-1825;
export FLIGHTS_SPEC_ID=c3Rvc-ZG9j-1826;


# GET AN ACCESS TOKEN
export ACCESS_TOKEN=$(curl -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" \
  -H "Accept: application/json;charset=utf-8" \
  -H "Authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" \
  -X POST https://login.e2e.apigee.net/oauth/token \
  -d 'username=kevinford@google.com&password=!n0r1t5@C&grant_type=password' | awk -F'"' '{print $4}')
echo "Access Token is: $ACCESS_TOKEN"


# GET ETAG FOR $SPEC_1_NAME SPEC
export ETAG_BAGGAGE=$(curl -i -X GET "https://e2e.apigee.net/$BAGGAGE_SPEC_ID" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: kevinford-eval" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo "Baggage ETag is: $ETAG_BAGGAGE"

# GET ETAG FOR FLIGHTS SPEC
export ETAG_FLIGHTS=$(curl -i -X GET "https://e2e.apigee.net/$FLIGHTS_SPEC_ID" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: kevinford-eval" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo "Flights ETag is: $ETAG_FLIGHTS"


echo "OpenAPI Specification - $SPEC_1_NAME: Updating Spec Content on Apigee Edge"
# UPDATE THE $SPEC_1_NAME SPEC
curl -i -X PUT "https://e2e.apigee.net/$BAGGAGE_SPEC_ID/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $ETAG_BAGGAGE" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/rates-spec.json

# GET EXISTING PUBLISHED $SPEC_1_NAME SPEC
export BAGGAGE_SPEC_ID=$(curl -X GET "http://kevinford-eval-test.e2e.apigee.net/get-spec-1" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest')
echo "BAGGAGE SPEC ID IS:::::::::::::::::: $BAGGAGE_SPEC_ID"

# GET EXISTING PUBLISHED FLIGHTS SPEC
export FLIGHTS_SPEC_ID=$(curl -X GET "http://kevinford-eval-test.e2e.apigee.net/get-spec-2" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest')
echo "FLIGHTS SPEC ID IS:::::::::::::::::: $FLIGHTS_SPEC_ID"

if [ "$BAGGAGE_SPEC_ID" != "0" ]; then
    echo "FOUND $SPEC_1_NAME SPEC -- CLEANING";
    # DELETE EXISTING PUBLISHED $SPEC_1_NAME SPEC
    curl -X DELETE "https://e2e.apigee.net/portals/api/sites/$DEV_PORTAL_SITE/apidocs/$BAGGAGE_SPEC_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "X-Org-Name: kevinford-eval" \
        -H "Accept: application/json, text/plain, */*" \
        -H 'X-Requested-With: XMLHttpRequest'
fi

if [ "$FLIGHTS_SPEC_ID" != "0" ]; then
    echo "FOUND FLIGHTS SPEC -- CLEANING";
    # DELETE EXISTING PUBLISHED FLIGHTS SPEC
    curl -X DELETE "https://e2e.apigee.net/portals/api/sites/$DEV_PORTAL_SITE/apidocs/$FLIGHTS_SPEC_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "X-Org-Name: kevinford-eval" \
        -H "Accept: application/json, text/plain, */*" \
        -H 'X-Requested-With: XMLHttpRequest'
fi



echo "OpenAPI Specification - $SPEC_1_NAME: Publishing Spec Apigee Edge Portal"
# PUBLISH THE $SPEC_1_NAME SPEC
curl -i -X POST "https://e2e.apigee.net/portals/api/sites/$DEV_PORTAL_SITE/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d "{
      \"title\": \"BaggageProduct\",
      \"description\": \"Access baggage details, logistics, and tracking.\",
      \"edgeAPIProductName\": \"BaggageProduct\",
      \"imageUrl\":\"/files/baggage-icon.png\",
      \"visibility\": true,
      \"anonAllowed\": true,
      \"specId\": \"baggage-spec\",
      \"specContent\": \"/$BAGGAGE_SPEC_ID/content\",
      \"orgname\": \"kevinford-eval\"
   }"



echo "OpenAPI Specification - FLIGHTS: Updating Spec Content on Apigee Edge"
# UPDATE THE FLIGHTS SPEC
curl -i -X PUT "https://e2e.apigee.net/$FLIGHTS_SPEC_ID/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $ETAG_FLIGHTS" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/currency-spec.json

echo "OpenAPI Specification - FLIGHTS: Publishing Spec Apigee Edge Portal"
# PUBLISH THE $SPEC_1_NAME SPEC
curl -i -X POST "https://e2e.apigee.net/portals/api/sites/$DEV_PORTAL_SITE/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d "{
      \"title\": \"FlightsProduct\",
      \"description\": \"Access flight details, schedules, cancellations, and delays.\",
      \"edgeAPIProductName\": \"FlightsProduct\",
      \"imageUrl\":\"/files/flights-icon.png\",
      \"visibility\": true,
      \"anonAllowed\": true,
      \"specId\": \"flights-spec\",
      \"specContent\": \"/$FLIGHTS_SPEC_ID/content\",
      \"orgname\": \"kevinford-eval\"
   }"
