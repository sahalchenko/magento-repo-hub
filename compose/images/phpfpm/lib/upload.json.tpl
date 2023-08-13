{
  "name":        "repo/upload",
  "description": "Private repository Extensions for Magento 2",
  "homepage":    "$LOCAL_URL/repository/upload",
  "output-html": true,
  "repositories": {
    "upload": {
    "type": "artifact",
    "url": "/rlib/upload"
    }
  },
  "require-all": true,
  "minmum-stability":"dev",
  "archive": {
    "skip-dev": true,
    "format": "zip",
    "directory": "dist",
    "ignore-filters": false,
    "override-dist-type": false
  }
}
