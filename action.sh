 #!/bin/bash

check_approver_membership() {
  local user="$1"
  local team_slug="$2"
  local token="$3"
  local owner="$4"

   # Validate required inputs
  if [ -z "$user" ] || [ -z "$team_slug" ] || [ -z "$owner" ] || [ -z "$token" ]; then
    echo "Error: Missing required parameters"
    echo "error-message=Missing required parameters: user, team_slug, owner, and token must be provided." >> "$GITHUB_OUTPUT"                        
    echo "result=failure" >> "$GITHUB_OUTPUT"
    return
  fi

   # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"
  local api_url="$api_base_url/orgs/$owner/teams/$team_slug/memberships/$user"
  
  RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/json" \
    "$api_url")
    
  echo "API Response Code: $RESPONSE"  
  cat response.json
  
  if [ "$RESPONSE" -eq 200 ]; then
    echo "result=success" >> $GITHUB_OUTPUT
    echo "is-member=true" >> $GITHUB_OUTPUT
    echo "User '$user' is a member of the '$team_slug' team."
  else
    echo "result=success" >> $GITHUB_OUTPUT
    echo "is-member=false" >> $GITHUB_OUTPUT
    echo "User '$user' is not a member of the '$team_slug' team."
  fi
  
  rm -f response.json
}
