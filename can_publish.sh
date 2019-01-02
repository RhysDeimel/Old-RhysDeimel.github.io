#!/usr/bin/env bash

for filename in content/drafts/*.md; do
    [ -e "$filename" ] || continue
    echo "should do some stuff here"
    # check files that contain "Status: ready"
        # check date is greater than or equal to today
            # change status to "published"
            # move to posts/(folder that matches year)
done


# todate=$(date -d 2013-07-18 +%s)
# cond=$(date -d 2014-08-19 +%s)

# if [ $todate -ge $cond ];
# then
#     break
# fi  