Title: Up and Running: Creating the Site With Pelican
Date: 2018-11-22
Category: HowTo
Tags: pelican, python, travis
Summary: GitHub Pages quickstart Pelican and Travis CI
Status: draft

<!-- Making user pages, which publishes from the master branch. So need to make a separate branch
https://help.github.com/articles/user-organization-and-project-pages/#user-and-organization-pages-sites

link http://docs.getpelican.com/en/stable/tips.html#publishing-to-github
Pelican has a plugin, `ghp-import`, which makes things easier
-->

# A Wonderful Bird Is the Pelican

Python. Pelican. A Blog so I don't have to remember the things I do. Awesome.

What did I do to get this thing up and running? What did I have in mind while doing it? Well, let me explain future me (or any other _not me_ reading this). I wanted somewhere to document things I have figured out, something that was internet accessable, and easy enough to get the ball rolling with. [GitHub Pages](https://pages.github.com/) is something I attempted before using their suggestion of [Jekyll](https://jekyllrb.com/]), but I could never be motivated enough to do anything because, well, _Ruby_. Having purged my previous attempt at a blog, I decided to give GitHub Pages a whirl, but this time putting in some extra effort to use [Pelican](https://blog.getpelican.com/). Given Python is my preferred language, let's hope this pans out better. Automatic deployment is something I also wanted, because it means I can write on whatever, and not have to worry about anything more that a `git push`. For this, [Travis CI](https://travis-ci.org/) -- because of GitHub integration -- is the obvious choice.

Now, not going to lie, but the default theme for Pelican is pretty heinous. [Sample themes](http://www.pelicanthemes.com/) don't really fare much better either. I guess the joke that Python developers only know how to make <s>ugly</s> functional web pages kinda pans out here... Anyway, with that in mind, I wanted to try my hand and creating my own theme. But with one caveat: I wanted to attempt frontend TDD. This is something I have not yet done, so it should be _interesting_.

With that in mind, here's what I did.

## His Beak Can Hold More Than His Belly Can

First off, the basics. You're going to need to create your directory, and then you should _probably_ create your virtual environment. You don't have to, but don't say I didn't warn you. Once you've activated your virtual envrionment (you did do that, right?), smash a `pip install pelican markdown ghp-import` into the console. You can see I've decided to install markdown, because I'd like to be able to write with it, but the next part -- `ghp-import` -- I'm reasonably certain I don't need. I think that's a relic from a first round attempt at automatic publishing. Maybe I'll revise this later and remove it (highly unlikely).

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

Lastly is travis integration. Hooking up was _fun_, as Travis usually is.






- travis has a deploy integration for github pages that is pretty much the same as the one in fabric. The only issue is figuring out the travis shenanigans. End result is the file I ended up with. `Script` will run future tests, `before_deploy` generates content, `deploy` pushes everything in the output dir to master.





