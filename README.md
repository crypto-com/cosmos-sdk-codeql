# cosmos-sdk-codeql
A query suite for common bug patterns in Cosmos SDK-based applications.

## Usage
In CodeQL CLI, you can download it using the following command:

```bash
$ codeql pack download crypto-com/cosmos-sdk-codeql@0.0.3
```

[See more details in the CodeQL CLI documentation](https://codeql.github.com/docs/codeql-cli/publishing-and-using-codeql-packs/).

In order to add the extra queries to the CI pipeline, you can use the `queries` or `packs` option in the CodeQL initialization:

```yaml
#...
    # Initializes the CodeQL tools for scanning.
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v1
      with:
        languages: 'go'
        queries: crypto-com/cosmos-sdk-codeql@v0.0.3, <...other queries...>
#...
```

[See more details in the GitHub Code Scanning documentation](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/configuring-code-scanning#running-additional-queries).