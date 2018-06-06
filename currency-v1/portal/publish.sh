#!/bin/bash

echo "PUBLISH: Developer Portal Documentation"
echo "Jenkins Workspace: $WORKSPACE"
echo "PWD: $PWD"
curContext=$(ls -l)
echo "CURRENT CONTEXT (Directories): $curContext"

#  Currency Spec is   c3Rvc-ZG9j-1855;
#  Rates Spec    is   c3Rvc-ZG9j-1856;


# GET AN ACCESS TOKEN
export ACCESS_TOKEN=$(curl -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" \
  -H "Accept: application/json;charset=utf-8" \
  -H "Authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" \
  -X POST https://login.e2e.apigee.net/oauth/token \
  -d 'username=kevinford@google.com&password=!n0r1t5@C&grant_type=password' | awk -F'"' '{print $4}')
echo "Access Token is: $ACCESS_TOKEN"



# GET ETAG FOR CURRENCY SPEC
export CURRENCY_ETAG=$(curl -i -X GET "https://e2e.apigee.net/c3Rvc-ZG9j-1855" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: kevinford-eval" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo "Currency Spec ETag is: $CURRENCY_ETAG"

# GET ETAG FOR RATES SPEC
export RATES_ETAG=$(curl -i -X GET "https://e2e.apigee.net/c3Rvc-ZG9j-1856" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-Org-Name: kevinford-eval" \
  -H "Accept: application/json, text/plain, */*" \
  -H 'X-Requested-With: XMLHttpRequest' | grep ETag: | awk -F' ' '{print $2}')
echo "Rates Spec ETag is: $RATES_ETAG"






echo "OpenAPI Specification - Currency Spec: Updating Spec Content on Apigee Edge"
# UPDATE THE Currency Spec SPEC
curl -i -X PUT "https://e2e.apigee.net/c3Rvc-ZG9j-1855/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $CURRENCY_ETAG" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/maintenance-spec.json


echo "OpenAPI Specification - RATES SPEC: Updating Spec Content on Apigee Edge"
# UPDATE THE RATES SPEC
curl -i -X PUT "https://e2e.apigee.net/c3Rvc-ZG9j-1856/content" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H "X-Requested-With: XMLHttpRequest" \
   -H "If-Match: $RATES_ETAG" \
   -H "Content-Type:application/x-yaml" \
   -d @currency-v1/portal/inventory-spec.json




# GET EXISTING PUBLISHED CURRENCY SPEC
export PORTAL_PUBLISHED_SPEC_ONE=$(curl -X GET "http://kevinford-eval-test.e2e.apigee.net/get-spec-1" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest')
echo "INVENTORY SPEC SPEC ID IS:::::::::::::::::: $PORTAL_PUBLISHED_SPEC_ONE"

# GET EXISTING PUBLISHED RATES SPEC FROM EDGE
export PORTAL_PUBLISHED_SPEC_TWO=$(curl -X GET "http://kevinford-eval-test.e2e.apigee.net/get-spec-2" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest')
echo "MAINTENANCE SPEC SPEC ID IS:::::::::::::::::: $PORTAL_PUBLISHED_SPEC_TWO"




if [ "$PORTAL_PUBLISHED_SPEC_ONE" != "0" ]; then
    echo "FOUND CURRENCY SPEC -- CLEANING";
    # DELETE EXISTING PUBLISHED $SPEC_1_NAME SPEC
    curl -X DELETE "https://e2e.apigee.net/portals/api/sites/kevinford-eval-boeing/apidocs/$PORTAL_PUBLISHED_SPEC_ONE" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "X-Org-Name: kevinford-eval" \
        -H "Accept: application/json, text/plain, */*" \
        -H 'X-Requested-With: XMLHttpRequest'
fi

echo "OpenAPI Specification - Inventory Spec: Publishing Spec Apigee Edge Portal"
# PUBLISH THE Maintenance SPEC
curl -i -X POST "https://e2e.apigee.net/portals/api/sites/kevinford-eval-boeing/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d "{
      \"title\": \"MaintenanceProduct\",
      \"description\": \"Access maintenance details, logistics, and tracking.\",
      \"edgeAPIProductName\": \"MaintenanceProduct\",
      \"imageUrl\":\"/files/maintenance-icon.png\",
      \"visibility\": true,
      \"anonAllowed\": true,
      \"specId\": \"maintenance-spec\",
      \"specContent\": \"/c3Rvc-ZG9j-1855/content\",
      \"orgname\": \"kevinford-eval\"
   }"




if [ "$PORTAL_PUBLISHED_SPEC_TWO" != "0" ]; then
    echo "FOUND RATES SPEC PUBLISHED TO PORTAL -- CLEANING";
    # DELETE EXISTING PUBLISHED RATES SPEC
    curl -X DELETE "https://e2e.apigee.net/portals/api/sites/kevinford-eval-boeing/apidocs/$PORTAL_PUBLISHED_SPEC_TWO" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "X-Org-Name: kevinford-eval" \
        -H "Accept: application/json, text/plain, */*" \
        -H 'X-Requested-With: XMLHttpRequest'
fi

echo "OpenAPI Specification - Rates Spec: Publishing Spec Apigee Edge Portal"
# PUBLISH THE RATES SPEC
curl -i -X POST "https://e2e.apigee.net/portals/api/sites/kevinford-eval-boeing/apidocs" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -H "X-Org-Name: kevinford-eval" \
   -H "Accept: application/json, text/plain, */*" \
   -H 'X-Requested-With: XMLHttpRequest' \
   -H "Content-Type: application/json" \
   -d "{
      \"title\": \"InventoryProduct\",
      \"description\": \"Access inventory details, schedules, movements, and trends.\",
      \"edgeAPIProductName\": \"InventoryProduct\",
      \"imageUrl\":\"/files/inventory-icon.png\",
      \"visibility\": true,
      \"anonAllowed\": true,
      \"specId\": \"rates-spec\",
      \"specContent\": \"/c3Rvc-ZG9j-1856/content\",
      \"orgname\": \"kevinford-eval\"
   }"
