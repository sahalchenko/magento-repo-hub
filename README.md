<h1 align="center">sahalchenko/magento-repo-hub</h1>

#### This script will help you consolidate and manage your Magento 2 repositories from a single source.


## Table of contents

- [Setup](#setup)
- [Use](#use)
- [Donations](#donations)
- [License](#license)

## Setup
```bash
# 1. Download the project (unzip) and cd project folder

# Chown permissions 
chown +x ./magesla.sh
```

## Use

1. before using the script, make a change to the ./compose/env file
2. make a change to the vendor permissions files located in ./templatees/$vendor/credentials.ini. You can add as many accesses as you want.
3. upload your modules to the ./upload folder, after running the script, these modules will be added to your repository
4. in the file ./templatees/github/extensions.txt add a list of available modules on github.

```bash
# Run script
./magesla.sh
```
#### Select options menu

0.  Exit  - Stop containers and exit the project
1.  Build - Build images --no-cache (only dev mode). You can attach local images for a build project
```
version: "3"
services:
  web:
    container_name: ${LOCAL_URL}
    build:
        context: ./images/nginx
  ... 
  # And for phpfpm as well.
        context: ./images/phpfpm
  ...       
```

2.  Start - Run containers before downloads
3.  Download   - Download repositories process. Select a single vendor number or select choice 1 to download all vendor ext
4.  Report     - Generate report all ext. See ./extension.csv file
5.  Sync       - Sync process between your local ext and remote server (See ./compose/env file)

## Donations
If you find it useful and want to invite us for a beer, just click on the donation button. Thanks!

[![Buy Me A Beer](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=TXZKTZ4555FH8)


## License

* [The MIT License](https://opensource.org/licenses/MIT)
