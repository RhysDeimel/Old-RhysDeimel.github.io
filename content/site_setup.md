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

# Some Title

Python. Pelican. A Blog so I don't have to remember the things I do. Awesome.

What did I do to get this thing up and running? What did I have in mind while doing it? Well, let me explain future me (or any other _not me_ reading this). I wanted somewhere to document things I have figured out, something that was internet accessable, and easy enough to get the ball rolling with. [GitHub Pages](https://pages.github.com/) is something I attempted before using their suggestion of [Jekyll](https://jekyllrb.com/]), but I could never be motivated enough to do anything because, well, _Ruby_. Having purged my previous attempt at a blog, I decided to give GitHub Pages a whirl, but this time putting in some extra effort to use [Pelican](https://blog.getpelican.com/). Given Python is my preferred language, let's hope this pans out better. Automatic deployment is something I also wanted, because it means I can write on whatever, and not have to worry about anything more that a `git push`. For this, [Travis CI](https://travis-ci.org/) -- because of GitHub integration -- is the obvious choice.

Now, not going to lie, but the default theme for Pelican is pretty heinous. [Sample themes](http://www.pelicanthemes.com/) don't really fare much better either. I guess the joke that Python developers only know how to make <s>ugly</s> functional web pages kinda pans out here... Anyway, with that in mind, I wanted to try my hand and creating my own theme. But with one caveat: I wanted to attempt frontend TDD. This is something I have not yet done, so it should be _interesting_.

With that in mind, here's what I did.



## Some SubHeader

New install with pelican 4.0.0
- create dir
    - create venv
    - install pelican `pip install pelican markdown ghp-import`
        pelican, markdown cause I want to write in markdown, and ghp-import so we can do things with github pages
    - add .gitignore [https://github.com/github/gitignore/blob/master/Python.gitignore]

`pelican-quickstart`

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
Done. Your new project is available at /mnt/c/Users/LucidNightmare/Coding/blog
```

make a test page in content:

```
Title: My First Review
Date: 2010-12-03 10:20
Category: Review

Following is a review of my favorite mechanical keyboard.
```

`pelican content`

`pelican --listen`


Hooking up to travis was _fun_
- travis has a deploy integration for github pages that is pretty much the same as the one in fabric. The only issue is figuring out the travis shenanigans. End result is the file I ended up with. `Script` will run future tests, `before_deploy` generates content, `deploy` pushes everything in the output dir to master.
