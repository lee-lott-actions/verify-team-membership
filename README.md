# Check Team Membership Action

This GitHub Action checks if a specified user is a member of a given team within an organization using the GitHub API. It returns a boolean indicating whether the user is a member (`true` for HTTP 200, `false` otherwise) and an error message if the user is not a member.

## Features
- Verifies user membership in a specified team via the GitHub API.
- Outputs a boolean (`is-member`) and an error message for easy integration into workflows.
- Requires a GitHub token with `read:org` scope for authentication.

## Inputs
| Name        | Description                                      | Required | Default |
|-------------|--------------------------------------------------|----------|---------|
| `user`      | The GitHub username to check for team membership. | Yes      | N/A     |
| `team-slug` | The slug of the team to check membership against. | Yes      | N/A     |
| `token`     | GitHub token with organization read access.      | Yes      | N/A     |
| `owner`     | The owner of the organization (user or organization). | Yes      | N/A     |

## Outputs
| Name           | Description                                           |
|----------------|-------------------------------------------------------|
| `result`       | Result of the action ("success" or "failure")         |
| `is-member`    | Boolean indicating if the user is a member of the team (`true` for HTTP 200, `false` otherwise). |
| `error_message`| Error message if the user is not a member of the team. |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/check-team-membership.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`), or the local path if stored in the same repository.

3. **Example Workflow**:
   ```yaml
   name: Check Team Membership
   on:
     issue_comment:
       types: [created]
   jobs:
     check-membership:
       runs-on: ubuntu-latest
       steps:
         - name: Check Team Membership
           id: check
           uses: lee-lott-actions/verify-team-membership@v1
           with:
             user: ${{ github.actor }}
             team-slug: 'my-team-slug'
             token: ${{ secrets.GITHUB_TOKEN }}
             owner: 'my-org'
         - name: Check Result
           run: |
             if [[ "${{ steps.check.outputs.is-member }}" == "true" ]]; then
               echo "User is authorized."
             else
               echo "${{ steps.check.outputs.error_message }}"
               exit 1
             fi
