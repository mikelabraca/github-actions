# Codeowners Labeler Action

This action automatically adds labels to a pull request based on the `CODEOWNERS` file.

## Inputs

- `github_token`: GitHub token to interact with GitHub API (required).

## Usage

```yaml
jobs:
  codeowners-labeler:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Codeowner PR
        uses: your-org/actions/packages/codeowners-labeler@main
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          codeowners_path: 'path/to/CODEOWNERS'