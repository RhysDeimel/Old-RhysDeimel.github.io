Title: Up and Running: Creating the Site With Pelican
Date: 2019-01-06
Category: howto
Tags: pelican, python, travis
Summary: GitHub Pages quickstart Pelican and Travis CI
Status: ready

# A Wonderful Bird Is the Pelican

Python. Pelican. A Blog so I don't have to remember the things I do. Awesome.

What did I do to get this thing up and running? What did I have in mind while doing it? Well, let me explain future me (or any other _not me_ reading this). I wanted somewhere to document things I have figured out, something that was internet accessible, and easy enough to get the ball rolling with.

[GitHub Pages](https://pages.github.com/) is something I attempted before using their suggestion of [Jekyll](https://jekyllrb.com/]), but I could never be motivated enough to do anything because, well, _Ruby_. Having purged my previous attempt at a blog, I decided to give GitHub Pages a whirl, but this time putting in some extra effort to use [Pelican](https://blog.getpelican.com/). Given Python is my preferred language, let's hope this pans out better. Automatic deployment is something I also wanted, because it means I can write on whatever, and not have to worry about anything more that a `git push`. For this, [Travis CI](https://travis-ci.org/) -- because of GitHub integration -- is the obvious choice.

Now, not going to lie, but the default theme for Pelican is pretty heinous. [Sample themes](http://www.pelicanthemes.com/) don't really fare much better. I guess the joke that Python developers only know how to make <s>ugly</s> functional web pages kinda pans out here... Anyway, with that in mind, I wanted to try my hand and creating my own theme. But with one caveat: I wanted to attempt frontend TDD. This is something I have not yet done, so it should be _interesting_.

With that in mind, here's what I did.

## His Beak Can Hold More Than His Belly Can

First off, the basics. You're going to need to create your directory, and then you should _probably_ create your virtual environment. You don't have to, but don't say I didn't warn you. Once you've activated your virtual environment (you did do that, right?), smash a `pip install pelican markdown ghp-import` into the console. You can see I've decided to install markdown, because I'd like to be able to write with it, but the next part (`ghp-import`) I'm reasonably certain I don't need. I think that's a relic from a first round attempt at automatic publishing. Maybe I'll revise this later and remove it (highly unlikely).

As of writing, Pelican is at version `4.0.0`, so if anything is funky, blame that. You might want to add a `.gitignore` also. I used Github's generic [Python.gitignore](https://github.com/github/gitignore/blob/master/Python.gitignore) because I'm lazy, but craft your own if that's your jam.

## He Can Hold in His Beak

Next up is getting off our `master` branch. You'll thank me later, so just create another with `git checkout -b src`. Once you're on your `src` branch, run `pelican-quickstart`. You'll be bombarded with a series of questions to help get your project up and running. I'm going to dump mine below for reference.

```
$ pelican-quickstart
Welcome to pelican-quickstart v4.0.0.

This script will help you create a new Pelican-based website.

Please answer the following questions so this script can generate the files
needed by Pelican.


> Where do you want to create your new web site? [.]
> What will be the title of this web site? RhysDeimel
> Who will be the author of this web site? Rhys Deimel
> What will be the default language of this web site? [en]
> Do you want to specify a URL prefix? e.g., https://example.com   (Y/n) n
> Do you want to enable article pagination? (Y/n) y
> How many articles per page do you want? [10]
> What is your time zone? [Europe/Paris] Australia/Sydney
> Do you want to generate a tasks.py/Makefile to automate generation and publishing? (Y/n) n
Done. Your new project is available at /mnt/c/Users/someawesomedir/blog
```

Pretty self explanatory for the most part. I'm aiming to make this blog a regular-_ish_ thing, so pagination is enabled. You'll notice I did choose to skip `tasks.py/Makefile` generation though. Travis will take care of that for me.

## Enough Food for a Week!

Time to make a test page in content. We'll just rip the example straight from the Pelican docs and place it in our `content` folder that should be sitting in our project root:

```
Title: My First Review
Date: 2010-12-03 10:20
Category: Review

Following is a review of my favorite mechanical keyboard.
```

Once we've created that file, we need to turn everything into a static site. Run `pelican content` and you should find that an `output` folder is created, and filled with html files. Progress! To preview it, all we need to do is throw `pelican --listen` into the command line, and we should find out blog being served at `http://localhost:8000/`. __Protip:__ throw in the `-r` flag if you'd like Pelican to rebuild every time it detects a change in the `content` folder.

## But I'll Be Darned If I Know How the Hellican?

Lastly is Travis integration. Personally, I find the Travis documentation a bit convoluted and hard to follow at times, so hooking it up was _fun_, but I did get there in the end. For publishing our blog, Travis has deploy integrations, and one of them is for [GitHub Pages](https://docs.travis-ci.com/user/deployment/pages/). It takes the output in a specified directory, and commits it to the specified branch. Using it seems a little more straight forward than some of the Pelican native implementations.

The following is the iteration of `travis.yml` at the time of writing

```yaml
dist: xenial
language: python
python:
  - "3.6"
branches:
  except:
    - master
install:
  - pip install -r requirements.txt
script:
  - echo "this would be where I run pytest..."
after_success:
  - ./can_publish.sh
before_deploy:
  - ./push.sh
  - pelican content
deploy:
  - provider: pages
    skip-cleanup: true
    github-token: $GITHUB_TOKEN
    local-dir: output
    target-branch: master
    keep_history: true
    verbose: true
    on:
      branch: src
```

There are a few points to note here; the `script` section is a placeholder. When I get around to making my own theme, pytest will be run there to support it. `after_success` contains a short bash script `can_publish.sh`. It's a workaround for the lack of Pelican draft to published pipeline. As of writing, there's no mechanism to automatically transition between the two. So instead, we can use a third status as a transition marker and script a change when we encounter it. We can also cross reference that marker with the post date and current date, and script scheduled posting via a Travis cron. Neat huh?

Below is the switching script for reference:

```bash
#!/usr/bin/env bash
today=$(date +%s)

echo "Checking to see if anything needs publishing"
for filename in content/drafts/*.md; do
    [ -e "$filename" ] || continue

    if grep -q "Status: ready" $filename; then
        echo "$(basename $filename) is finalised"
        post_date=$(grep Date $filename | cut -d' ' -f2)
        # can't pipe to date without headaches, hence the following
        post_date=$(date -d $post_date +%s)

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
```

`can_publish.sh` also moves files around for organisational reasons, so the next script (`push.sh`) in `before_deploy` commits and pushes the changes to the `src` branch. 

```bash
#!/usr/bin/env bash

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

echo "Adding any changes in content:"
git add content
git commit --message "[travis skip] CI Housekeeping: $TRAVIS_BUILD_NUMBER"

echo "Pushing any changes in content:"
git push -u https://RhysDeimel:$GITHUB_TOKEN@github.com/RhysDeimel/RhysDeimel.github.io.git/ HEAD:src

```
One thing we have to be aware of is that Travis, by default, builds on any remote change. So we will end up with double builds. That can be avoided if you instruct  Travis to [skip the build](https://docs.travis-ci.com/user/customizing-the-build/#skipping-a-build) by adding a keyword in the commit message, `travis skip` in this case.

The `push` command is also a little atypical in that Travis checks out a specific commit, resulting in a detached head. This means we need to specify the upstream location with `-u`, and also specify the branch we want to commit to. You can see the format below:
```
git push -u https://<username>:<personal_access_token>@github.com/<account_name>/<project>.git/ HEAD:<branch>
```

Lastly, the `deploy` section is relatively cookiecutter. For everything on the `src` branch generated in the content folder by `pelican content`, push it to master.

And there we have it, a decent Pelican blog with Travis setup.