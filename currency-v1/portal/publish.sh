#!/bin/bash

echo -e "\n\nPUBLISH: Developer Portal Documentation"
echo -e "\n\nJenkins Workspace: $WORKSPACE"
echo -e "\n\nPWD: $PWD"
curContext=$(ls -l)
echo -e "\n\nCURRENT CONTEXT (Directories): $curContext"
SITE_NAME=pandora

# GET ACCESS TOKEN
export ACCESS_TOKEN=$(curl -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" \
  -H "Accept: application/json;charset=utf-8" \
  -H "Authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" \
  -X POST https://login.apigee.com/oauth/token \
  -d 'username=kevinford@google.com&password=!n0r1t5@C&grant_type=password' | awk -F'"' '{print $4}')
echo -e "\n\nAccess Token is: $ACCESS_TOKEN"



# GET CONTENTS OF SPECS HOME FOLDER  <-- not necessary -- get the folder from the spec details themselves
# curl -X GET "https://apigee.com/homeFolder/contents" \
#   -H "Authorization: Bearer $ACCESS_TOKEN" \
#   -H "X-Org-Name: demo007" \
#   -H "Accept: application/json, text/plain, */*"


# Get the Currency Spec
export CURRENCY_SPEC_PATH_SEGMENT=$(curl -X GET "https://apigee.com/homeFolder/contents" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: demo007" -H "Accept: application/json, text/plain, */*" \
  | jq --raw-output '.contents | .[] | select(.name == "currency-spec-nb") | .self')
echo -e "\n\nCurrency Spec Path Segment is: $CURRENCY_SPEC_PATH_SEGMENT"

# Get the Rates Spec
export RATES_SPEC_PATH_SEGMENT=$(curl -X GET "https://apigee.com/homeFolder/contents" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: demo007" -H "Accept: application/json, text/plain, */*" \
  | jq --raw-output '.contents | .[] | select(.name == "rates-spec-nb") | .self')
echo -e "\n\nRates Spec Path Segment is: $RATES_SPEC_PATH_SEGMENT"

# Get ETag for Currency Spec
export CURRENCY_ETAG=$(curl -i -X GET "https://apigee.com$CURRENCY_SPEC_PATH_SEGMENT/content" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: demo007" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo -e "\n\nCurrency Spec ETag is: $CURRENCY_ETAG"

# Get ETag for Rates Spec
export RATES_ETAG=$(curl -i -X GET "https://apigee.com$RATES_SPEC_PATH_SEGMENT/content" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: demo007" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo -e "\n\nRates Spec ETag is: $RATES_ETAG"



echo -e "\n\nOpenAPI Specification - Currency Spec: Updating Spec Content on Apigee Edge"
# UPDATE THE Currency Spec
curl -i -X PUT "https://apigee.com$CURRENCY_SPEC_PATH_SEGMENT/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: demo007" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $CURRENCY_ETAG" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/currency-spec.json

echo -e "\n\nOpenAPI Specification - Rates Spec: Updating Spec Content on Apigee Edge"
# UPDATE THE Rates Spec
curl -i -X PUT "https://apigee.com$RATES_SPEC_PATH_SEGMENT/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: demo007" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $RATES_ETAG" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/rates-spec.json





# GET EXISTING PUBLISHED CURRENCY SPEC
#export PORTAL_PUBLISHED_SPEC_ONE=$(curl -X GET "http://demo007-test.e2e.apigee.net/get-spec-1" \
#   -H "Authorization: Bearer $ACCESS_TOKEN" \
#   -H "X-Org-Name: demo007" \
#   -H "Accept: application/json, text/plain, */*" \
#   -H 'X-Requested-With: XMLHttpRequest')
#echo -e "\n\nINVENTORY SPEC SPEC ID IS:::::::::::::::::: $PORTAL_PUBLISHED_SPEC_ONE"

# GET EXISTING PUBLISHED RATES SPEC FROM EDGE
#export PORTAL_PUBLISHED_SPEC_TWO=$(curl -X GET "http://demo007-test.e2e.apigee.net/get-spec-2" \
#   -H "Authorization: Bearer $ACCESS_TOKEN" \
#   -H "X-Org-Name: demo007" \
#   -H "Accept: application/json, text/plain, */*" \
#   -H 'X-Requested-With: XMLHttpRequest')
#echo -e "\n\nMAINTENANCE SPEC SPEC ID IS:::::::::::::::::: $PORTAL_PUBLISHED_SPEC_TWO"

# Get currency spec published to portal



export CURRENCY_SPEC_ON_PORTAL=$(curl -X GET "https://apigee.com/portals/api/sites/demo007-$SITE_NAME/apidocs" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: demo007" \
  -H "Accept: application/json, text/plain, */*" -H 'X-Requested-With: XMLHttpRequest' \
  | jq --raw-output '.data | .[] | select(.apiId == "finance-product-trial") | .id')
echo -e "\n\nCurrency Spec ID is:::::::::::::::::: $CURRENCY_SPEC_ON_PORTAL"

export RATES_SPEC_ON_PORTAL=$(curl -X GET "https://apigee.com/portals/api/sites/demo007-$SITE_NAME/apidocs" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: demo007" \
  -H "Accept: application/json, text/plain, */*" -H 'X-Requested-With: XMLHttpRequest' \
  | jq --raw-output '.data | .[] | select(.apiId == "finance-product-premium") | .id')
echo -e "\n\nRates Spec ID is:::::::::::::::::: $RATES_SPEC_ON_PORTAL"



# CLEAN UP EXISTING DOCS
if [ -z "$CURRENCY_SPEC_ON_PORTAL" ]
then
    echo -e "\n\nCurrency Spec not found on portal"
else
    echo -e "\n\nCurrency Spec EXISTS on Portal -- CLEANING";
    # DELETE EXISTING PUBLISHED Currency SPEC
    url="https://apigee.com/portals/api/sites/demo007-$SITE_NAME/apidocs/$CURRENCY_SPEC_ON_PORTAL"
    echo -e "\n\nIssue DELETE to: $url\n\n"
    curl -X DELETE "$url" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "X-Org-Name: demo007" \
        -H "Accept: application/json, text/plain, */*" \
        -H 'X-Requested-With: XMLHttpRequest'
fi

if [ -z "$RATES_SPEC_ON_PORTAL" ]
then
    echo -e "\n\nRates Spec not found on portal"
else
    echo -e "\n\nRates Spec EXISTS on Portal -- CLEANING";
    # Delete existing Rates Spec
    url="https://apigee.com/portals/api/sites/demo007-$SITE_NAME/apidocs/$RATES_SPEC_ON_PORTAL"
    echo -e "\n\nIssue DELETE to: $url"
    curl -X DELETE "$url" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "X-Org-Name: demo007" \
        -H "Accept: application/json, text/plain, */*" \
        -H 'X-Requested-With: XMLHttpRequest'
fi


echo -e "\n\nPublish Premium Finance Product to Portal"
# Publish Premium Finance Product to Portal
curl -i -X POST "https://apigee.com/portals/api/sites/demo007-$SITE_NAME/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: demo007" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d "{
      \"title\": \"Currency Product (Premium)\",
      \"description\": \"This product provides premium access to the Currency API. Traffic volume is limited to 100,000 requests per day.\",
      \"edgeAPIProductName\": \"finance-product-premium\",
      \"imageUrl\":\"/files/currency-icon.png\",
      \"visibility\": true,
      \"anonAllowed\": true,
      \"specId\": \"currency-spec-nb\",
      \"specContent\": \"$CURRENCY_SPEC_PATH_SEGMENT/content\",
      \"orgname\": \"demo007\"
   }"


echo -e "\n\nPublish Trial Finance Product to Portal"
# Publish Trial Finance Product to Portal
curl -i -X POST "https://apigee.com/portals/api/sites/demo007-$SITE_NAME/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: demo007" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d "{
      \"title\": \"Currency Product (Trial)\",
      \"description\": \"This product provides limited access to the Currency API. Traffic volume is limited to 5 requests per minute.\",
      \"edgeAPIProductName\": \"finance-product-trial\",
      \"imageUrl\":\"/files/currency-icon-free.png\",
      \"visibility\": true,
      \"anonAllowed\": true,
      \"specId\": \"currency-spec-nb\",
      \"specContent\": \"$CURRENCY_SPEC_PATH_SEGMENT/content\",
      \"orgname\": \"demo007\"
   }"

