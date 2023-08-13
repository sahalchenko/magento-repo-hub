<h1 align="center">sahalchenko/magento-repo-hub</h1>

#### This script will help you consolidate and manage your Magento 2 repositories from a single source.


## Table of contents

- [Setup](#setup)
- [Used](#used)
- [Donations](#donations)
- [License](#license)

## Setup
```bash
# 1. Download project (unzip) and cd project folder

# Chown permissions 
chown +x ./magesla.sh
```

## Used

1. before using the script, make a change to the ./compose/env file
2. make a change to the vendor permissions files located in ./templatees/$vendor/credentials.ini. You can add as many accesses as you want.
3. upload your modules to the ./upload folder, after running the script, these modules will be added to your repository
4. in the file ./templatees/github/extensions.txt add a list of available modules on github.

```bash
# Run script
./magesla.sh
```
#### Select options menu

0.  Exit  - Stop containers and exit project
1.  Build - Build images --no-cache (only dev mode). You can attache local images for build project
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
3.  Download   - Download repositories process. Select single vendor number or select choice 1 for download all vendor ext
4.  Report     - Generate report all ext. See ./extension.csv file
5.  Sync       - Sync process between your local ext and remote server (See ./compose/env file)

## Donations
If you find it useful and want to invite us for a beer, just click on the donation button. Thanks!

<form action="https://www.paypal.com/donate" method="post" target="_top">
<input type="hidden" name="hosted_button_id" value="TXZKTZ4555FH8" />
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
<img alt="" border="0" src="https://www.paypal.com/en_UA/i/scr/pixel.gif" width="1" height="1" />
</form>

## License

* [The MIT License](https://opensource.org/licenses/MIT)
