#!/usr/bin/env bash
today=$(date +%s)

for filename in content/drafts/*.md; do
    [ -e "$filename" ] || continue

    # check files that contain "Status: ready"
    if grep -q "Status: ready" $filename; then
        echo "$filename contains ready"
        post_date=$(grep "Date" $filename | cut -d' ' -f2 | date -d +%s)

        if [ "$today" -ge "$post_date" ]; then
            echo "$filename should be published"
        fi

    fi
    
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