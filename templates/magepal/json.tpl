{
  "name":        "$VENDOR/repo$block",
  "description": "$VENDOR Extensions for Magento 2",
  "homepage":    "$LOCAL_URL/repository/$VENDOR/$block",
  "output-html": true,
  "repositories": {
    "$URL": {
      "type": "composer",
      "url": "https://$URL/"
    }
  },
  "require-all":              true,
  "require-dependencies":     true,
  "require-dev-dependencies": false,
  "only-best-candidates":     true,
  "providers":                true,
  "archive": {
    "skip-dev":               true,
    "format":                 "zip",
    "directory":              "dist"
  }
}