# cosmos-sdk-codeql
A query suite for common bug patterns in Cosmos SDK-based applications.

## Usage
In CodeQL CLI, you can download it using the following command:

```bash
$ codeql pack download crypto-com/cosmos-sdk-codeql@0.0.5
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
        queries: crypto-com/cosmos-sdk-codeql@v0.0.5, <...other queries...>
#...
```

[See more details in the GitHub Code Scanning documentation](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/configuring-code-scanning#running-additional-queries).

## False Negatives
The queries have heuristics based on the usage in the Cosmos SDK codebase to reduce false positives.
They may, however, lead to false negatives: for example, if you used "client" package's code parts (that may be ignored by queries)
in consensus-critical sections, related bugs from ignored packages may not be uncovered by queries.
If you are worried about false negatives in particular queries, [you can open an issue to discuss the query change](https://github.com/crypto-com/cosmos-sdk-codeql/issues/new).
Alternatively, you can tweak the query and either execute it manually from time to time, or add the tweaked query to your CI scanning action.

## False Positives
The queries over-approximate and may lead to false positives. If you encounter a false positive, you can do the following:

1. [you can dismiss the false positive alerts in the Security tab on GitHub](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/managing-code-scanning-alerts-for-your-repository#dismissing--alerts);
2. if see a repeating pattern of false positives, [you can open an issue to discuss the query improvement](https://github.com/crypto-com/cosmos-sdk-codeql/issues/new);
3. alternatively, if you cannot dismiss alerts in the Security tab on GitHub, 
some of the queries will ignore findings that have an explicit comment (starting with "SAFE:")
that explains why it is safe to ignore that bit of code. The comments can be placed either on the preceding line or on the enclosing function:

```go
// SAFE: ...explanation why findings in this function are false positives...
func myFun(...) {
   ...
}

func myFun2(...) {
  ...
  // SAFE: ...explanation why this particular finding is a false positive...
  myVar := ...
  ...
}
```