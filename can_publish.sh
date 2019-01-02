#!/usr/bin/env bash
today=$(date +%s)

for filename in content/drafts/*.md; do
    [ -e "$filename" ] || continue

    if grep -q "Status: ready" $filename; then
        echo "$(basename $filename) is finalised"
        post_date=$(grep Date $filename | cut -d' ' -f2 | date +%s)

        if [ "$today" -ge "$post_date" ]; then
            echo "$(basename $filename) should be published"
            echo "today is $today"
            echo "post_date is $post_date"

            sed -i 's/Status: ready/Status: published/' $filename
            mkdir -p content/posts/$(date +%Y)/
            mv $filename content/posts/$(date +%Y)/$(basename $filename)
        else
            echo "Publish date has not been reached, skipping."
        fi
    fi
done
