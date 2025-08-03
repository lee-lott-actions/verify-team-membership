#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f response.json "$GITHUB_OUTPUT" mock_response.json
}

@test "check_approver_membership succeeds with HTTP 200" {
  echo '{"state": "active", "role": "member"}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run check_approver_membership "test-user" "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'is-member' "$GITHUB_OUTPUT")" == "is-member=true" ]
}

@test "check_approver_membership fails with HTTP 404 (not a member)" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run check_approver_membership "test-user" "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'is-member' "$GITHUB_OUTPUT")" == "is-member=false" ]
}

@test "check_approver_membership fails with empty user" {
  run check_approver_membership "" "test-team" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: user, team_slug, owner, and token must be provided." ]
}

@test "check_approver_membership fails with empty team_slug" {
  run check_approver_membership "test-user" "" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: user, team_slug, owner, and token must be provided." ]
}

@test "check_approver_membership fails with empty token" {
  run check_approver_membership "test-user" "test-team" "" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: user, team_slug, owner, and token must be provided." ]
}

@test "check_approver_membership fails with empty owner" {
  run check_approver_membership "test-user" "test-team" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: user, team_slug, owner, and token must be provided." ]
}
