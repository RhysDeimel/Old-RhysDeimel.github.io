#!/usr/bin/env bash
set -e

today=$(date +%s)

echo "Checking to see if anything needs publishing"
for filename in content/drafts/*.md; do
    [ -e "$filename" ] || continue

    if grep -q "Status: ready" $filename; then
        echo "$(basename $filename) is finalised"
        post_date=$(grep Date $filename | head -1 | cut -d' ' -f2)
        post_date=$(date -d "$post_date" +%s)

        if [ "$today" -ge "$post_date" ]; then
            echo "$(basename $filename) should be published"

            sed -i 's/Status: ready/Status: published/' $filename
            mkdir -p content/posts/$(date +%Y)/
            mv $filename content/posts/$(date +%Y)/$(basename $filename)
        else
            echo "Publish date has not been reached, skipping."
        fi
    fi
done
