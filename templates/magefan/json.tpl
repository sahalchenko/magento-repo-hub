{
  "name":        "$VENDOR/repo$block",
  "description": "$VENDOR Extensions for Magento 2",
  "homepage":    "$LOCAL_URL/repository/$VENDOR/$block",
  "output-html": true,
  "repositories": {
    "$URL": {
      "type": "composer",
      "url": "https://$URL/repo"
    }
  },
  "require-all":              true,
  "require-dependencies":     false,
  "require-dev-dependencies": false,
  "providers":                true,
  "archive": {
    "skip-dev":               true,
    "ignore-filters":         false,
    "override-dist-type":     false,
    "format":                 "zip",
    "directory":              "dist"
  }
}