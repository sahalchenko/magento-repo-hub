#!/bin/bash

dirTemplates="/templates"
dirRunner="/runner"
dirHtml="/var/www/html"
dirRepository="$dirHtml/repository"
dirRLib="/rlib"

fileSatisJson="json.tpl"
fileAuthJson="auth.json.tpl"
fileVendorJson="vendor.json.tpl"
filePublicJson="public.json.tpl"
fileVendorPass="credentials.ini"
fileGitHubTxt="$dirRunner/github/extensions.txt"
fileGitHubRender="$dirRunner/github/render.txt"


# clear runner folder
function clearRunner() {
   rm -rf  $dirRunner/*
}

function upload() {
 # prepare json for private repo
 mkdir -p $dirRepository/upload &>/dev/null

 cat $dirRLib/upload.json.tpl | sed -e "s~\$LOCAL_URL~https://${LOCAL_URL}~g" > $dirRepository/upload.json
 satis build $dirRepository/upload.json $dirRepository/upload --skip-errors

}

# download repository
function download() {

# array vendors in runner
vendors=$(find "$dirRunner" -type d -mindepth 1 -maxdepth 1 -exec sh -c 'basename "$0"' {} \;)

# vendor block in runner
 for vendor in $vendors; do

   # array vendor blocks
   blocks=$(grep -o '\[[[:alnum:].]\+\]' "$dirRunner/$vendor/$fileVendorPass" | sed 's/\[//;s/\]//')

   # set null array for group vendor
   groupVendor=()

   # get vendor block
   for block in $blocks; do

         # prepare structure
         rm -rf $dirRepository/$vendor/${block}.json /root/.composer && mkdir -p $dirRepository/$vendor/${block} /root/.composer

         # prepare json format
         dos2unix $dirRunner/$vendor/$fileSatisJson $dirRunner/$vendor/$fileVendorPass $dirRLib/$fileAuthJson

         # get values from credential file
         USER=$(sed -n '/^\['"$block"'\]/,/^\[/{/^\[/d; s/USER=//; /^PASS/d; p}' $dirRunner/$vendor/$fileVendorPass | tr -d '\n')
         PASS=$(sed -n '/^\['"$block"'\]/,/^\[/{/^\[/d; s/PASS=//; /^USER/d; p}' $dirRunner/$vendor/$fileVendorPass | tr -d '\n')
         URL=$(grep -E 'URL\s*=' $dirRunner/$vendor/$fileVendorPass | sed 's/URL\s*=\s*//g' | cut -d' ' -f1)

        # insert credentials to /root/.composer/auth.json
         if [ -f $dirRLib/$fileAuthJson ]; then
             cat $dirRLib/$fileAuthJson | sed \
               -e "s~\$USER~${USER}~g" \
               -e "s~\$PASS~${PASS}~g" \
               -e "s~\$URL~${URL}~g" > /root/.composer/auth.json

         # insert credentials to satis json for vendor
           cat $dirRunner/$vendor/$fileSatisJson | sed \
             -e "s~\$LOCAL_URL~https://${LOCAL_URL}~g" \
             -e "s~\$REPO_PATH~${REPO_PATH}~g" \
             -e "s~\$URL~${URL}~g" \
             -e "s~\$VENDOR~${vendor}~g" \
             -e "s~\$USER~${USER}~g" \
             -e "s~\$PASS~${PASS}~g" \
             -e "s~\$block~${block}~g" >$dirRepository/$vendor/${block}.json
         fi

        # build satis for vendor block
        satis build $dirRepository/$vendor/${block}.json $dirRepository/$vendor/${block} --skip-errors

    # set list vendor blocks
    groupVendor+=("https://$LOCAL_URL/repository/$vendor/$block")
  done

      ################ PREPARE SATIS JSON FILE MASS VENDOR ################
      fileVendorGroupJson="$dirRepository/$vendor/groupVendor.json"
      echo "{" > "$fileVendorGroupJson"
      echo "  \"name\": \"repo/$vendor\"," >> "$fileVendorGroupJson"
      echo "  \"homepage\": \"https://$LOCAL_URL/repository/$vendor\"," >> "$fileVendorGroupJson"
      echo "  \"description\": \"Repository Extensions\"," >> "$fileVendorGroupJson"
      echo "  \"output-html\": true," >> "$fileVendorGroupJson"
      echo "  \"repositories\": [" >> "$fileVendorGroupJson"
      for line in "${groupVendor[@]}"; do
        line=$(echo "$line" | tr -d '\r\n')
        echo "    {" >> "$fileVendorGroupJson"
        echo "      \"type\": \"composer\"," >> "$fileVendorGroupJson"
        echo "      \"url\": \"$line\"" >> "$fileVendorGroupJson"
        echo "    }," >> "$fileVendorGroupJson"
      done
      sed -i '$ s/,$//' "$fileVendorGroupJson" # Remove the trailing comma from the last JSON object
      echo "  ]," >> "$fileVendorGroupJson"
      # Write the remaining fields to the JSON object
      echo "  \"require-all\": true," >> "$fileVendorGroupJson"
      echo "  \"archive\": {" >> "$fileVendorGroupJson"
      echo "     \"skip-dev\": true," >> "$fileVendorGroupJson"
      echo "     \"format\": \"zip\"," >> "$fileVendorGroupJson"
      echo "     \"directory\": \"dist\" " >> "$fileVendorGroupJson"
      echo "  }," >> "$fileVendorGroupJson"
      echo "  \"providers-history-size\": 3," >> "$fileVendorGroupJson"
      echo "  \"require-dependencies\": false," >> "$fileVendorGroupJson"
      echo "  \"require-dev-dependencies\": false," >> "$fileVendorGroupJson"
      echo "  \"only-best-candidates\": true," >> "$fileVendorGroupJson"
      echo "  \"providers\": true" >> "$fileVendorGroupJson"
      echo "  }" >> "$fileVendorGroupJson"

  # build satis for group vendor
  dos2unix $fileVendorGroupJson
  satis build $fileVendorGroupJson $dirRepository/$vendor/ --skip-errors
done

   ################ PREPARE SATIS JSON FILE GITHUB ################
        # if runner has github folder
        if [ -f $fileGitHubTxt ]; then

          mkdir -p $dirRepository/github

          for line in $fileGitHubTxt; do
            grep '^https://github.com' "$line" >> $fileGitHubRender
          done

          grep -v '^[[:space:]]*$' $fileGitHubRender
          sort $fileGitHubRender | uniq > $fileGitHubRender.tmp
          rm $fileGitHubRender && mv $fileGitHubRender.tmp $fileGitHubRender

          ################ PREPARE GITHUB JSON FILE ################
          fileGitHubJson="$dirRepository/github/github.json"

          echo "{" > $fileGitHubJson
          echo "  \"name\": \"repo/github\"," >> $fileGitHubJson
          echo "  \"homepage\": \"https://$LOCAL_URL/repository/github\"," >> $fileGitHubJson
          echo "  \"output-html\": true," >> $fileGitHubJson
          echo "  \"repositories\": [" >> $fileGitHubJson
          while read -r line || [ -n "$line" ]; do
            line=$(echo $line | tr -d '\r\n')
            echo "    {" >> $fileGitHubJson
            echo "      \"type\": \"vcs\"," >> $fileGitHubJson
            echo "      \"url\": \"$line\"" >> $fileGitHubJson
            echo "    }," >> $fileGitHubJson
          done < "$fileGitHubRender"
          sed -i '$ s/,$//' $fileGitHubJson # Remove the trailing comma from the last JSON object
          echo "  ]," >> $fileGitHubJson
          echo "  \"require-all\": true," >> $fileGitHubJson
          echo "  \"archive\": {" >> $fileGitHubJson
          echo "     \"skip-dev\": true," >> $fileGitHubJson
          echo "     \"format\": \"zip\"," >> $fileGitHubJson
          echo "     \"directory\": \"dist\" " >> $fileGitHubJson
          echo "  }," >> $fileGitHubJson
          echo "  \"require-dependencies\": false," >> $fileGitHubJson
          echo "  \"require-dev-dependencies\": false," >> $fileGitHubJson
          echo "  \"only-best-candidates\": true," >> $fileGitHubJson
          echo "  \"providers\": true," >> $fileGitHubJson
          echo "  \"providers-history-size\": 3," >> $fileGitHubJson
          echo "  \"config\": {" >> $fileGitHubJson
          echo "    \"preferred-install\": \"dist\"," >> $fileGitHubJson
          echo "    \"github-protocols\": [\"https\",\"http\"]," >> $fileGitHubJson
          echo "    \"github-oauth\": {" >> $fileGitHubJson
          echo "      \"github.com\": \"$GIT_TOKEN\"" >> $fileGitHubJson
          echo "    }" >> $fileGitHubJson
          echo "  }" >> $fileGitHubJson
          echo "}" >> $fileGitHubJson

          satis build $fileGitHubJson $dirRepository/github/ --skip-errors
        fi



   ################ PREPARE SATIS JSON FILE MASS VENDOR ################
   # array vendors in runner
   allVendors=$(find "$dirRepository" -type d -mindepth 1 -maxdepth 1 -exec sh -c 'basename "$0"' {} \;)

   # set null array for group all vendors
   groupAllVendors=()

   # vendor block in runner
   for groupVendor in $allVendors; do
    # set list all vendors
    groupAllVendors+=("https://$LOCAL_URL/repository/$groupVendor/")
   done

   fileAllVendorsJson="$dirRepository/allVendors.json"
    echo "{" > "$fileAllVendorsJson"
    echo "  \"name\": \"repo/all\"," >> "$fileAllVendorsJson"
    echo "  \"homepage\": \"https://$LOCAL_URL/\"," >> "$fileAllVendorsJson"
    echo "  \"description\": \"Repository Extensions\"," >> "$fileAllVendorsJson"
    echo "  \"output-html\": true," >> "$fileAllVendorsJson"
    echo "  \"repositories\": [" >> "$fileAllVendorsJson"
    for lines in "${groupAllVendors[@]}"; do
     lines=$(echo "$lines" | tr -d '\r\n')
     echo "    {" >> "$fileAllVendorsJson"
     echo "      \"type\": \"composer\"," >> "$fileAllVendorsJson"
     echo "      \"url\": \"$lines\"" >> "$fileAllVendorsJson"
     echo "    }," >> "$fileAllVendorsJson"
    done
     sed -i '$ s/,$//' "$fileAllVendorsJson" # Удаление лишней запятой после последнего объекта JSON
     echo "  ]," >> "$fileAllVendorsJson"
     echo "  \"require-all\": true," >> "$fileAllVendorsJson"
     echo "  \"archive\": {" >> "$fileAllVendorsJson"
     echo "     \"skip-dev\": true," >> "$fileAllVendorsJson"
     echo "     \"format\": \"zip\"," >> "$fileAllVendorsJson"
     echo "     \"directory\": \"dist\" " >> "$fileAllVendorsJson"
     echo "  }," >> "$fileAllVendorsJson"
     echo "  \"providers-history-size\": 3," >> "$fileAllVendorsJson"
     echo "  \"require-dependencies\": false," >> "$fileAllVendorsJson"
     echo "  \"require-dev-dependencies\": false," >> "$fileAllVendorsJson"
     echo "  \"only-best-candidates\": true," >> "$fileAllVendorsJson"
     echo "  \"providers\": true" >> "$fileAllVendorsJson"
     echo "}" >> "$fileAllVendorsJson"

   dos2unix $fileAllVendorsJson
   satis build $fileAllVendorsJson $dirHtml --skip-errors
}


# copy directory
copy_directory() {
    local source_dir="$1"
    local destination_dir="$2"

    cp -R "$source_dir" "$destination_dir"
}

# main menu
main_menu() {
    local options=("Exit" "All")
    local vendors=("$dirTemplates"/*)

    for vendor in "${vendors[@]}"; do
        options+=("$(basename "$vendor")")
    done

    while true; do
        echo "Select vendor option for download:"

        for ((i=0; i<${#options[@]}; i++)); do
            echo "$i. ${options[$i]}"
        done

        read -p "Select choice: " choice

        if [ "$choice" -ge 0 ] && [ "$choice" -lt ${#options[@]} ]; then
            local selected_option="${options[$choice]}"

            if [ "$selected_option" == "Exit" ]; then
                break
            elif [ "$selected_option" == "All" ]; then
                for sub_dir in "${vendors[@]}"; do
                    copy_directory "$sub_dir" "$dirRunner"
                done
                    upload
                    download
                    clearRunner
            else
                local sub_dir="$dirTemplates/$selected_option"
                if [ -d "$sub_dir" ]; then
                    copy_directory "$sub_dir" "$dirRunner"
                    upload
                    download
                    clearRunner
                else
                    echo "Folder $sub_dir not found"
                fi
            fi
        else
            echo "Invalid option"
        fi
    done
}

main_menu
