# Features
## Shared path per site
All content within one site shares a path to be as similar to a regular site as possible.
This means your index.html can refer to a /img/logo.png just like you normally would.

## Nested layouts
Your blog articles can have an article layout, but still use your site-layout:

Say you have an article.html and some layouts:

- article.html, layout: article_layout
- article_layout, layout: application_layout
- application_layout

Scribo will render `article.html` in the `article_layout`, which will be rendered in the `application_layout`

## Liquid templating
All text-based content is rendered through [liquid](http://liquidmarkup.org)
This means you can do powerful things with your pages, layouts but even stylesheets.

To every content we render, we add the `content` local, this means you can access content information in the content we render:

index.html:

```html
<html>
    <head>
        <title>{{content.title}}</title>
        <meta name="title" content="{{content.title}}"/>
        <meta name="description" content="{{content.description}}"/>
        <meta name="keywords" content="{{content.keywords}}"/>
    </head>
    <body>
        <h1>Navigation</h1>
        <ul>
            {%for c in content.sites.contents%}
            <li><a href="{{c.path}}">{{c.title}}</a></li>
            {%endfor%}
        </ul>
    </body>
</html>
```

We added a few useful liquid tags to help you create content:

### yield

Usage: {% yield ['name'] %}.

Normal {% yield %} is used to render content in a layout. {% yield 'name' %} is used to render named content.

### content_for

Usage: {% content_for ['name'] %}

In content you can add content to specific sections of your layout.
Say you have a sidebar defined in your layout, you can add content to that using:

{% content_for 'sidebar' %}
This is <b>sidebar</b> content.
{% endcontentfor %}

### include

Usage: {% include 'identifier' %}

Will include the content from the identified content.

Example:

```
{% include 'menu' %}
```

Will look for content with identifier 'menu' and include that.


## Filters
Because we use [Slim](http://slim-lang.com) and [Tilt](https://github.com/rtomayko/tilt), all text-based content can be run through additional filters like Markdown, Slim, Haml and Sass.

If you add content and set filter to 'markdown', Scribo will render that content using markdown.

## Nested content (not enabled)
Content can have child content, this allows for blog-like structure (rendering is done by parent).
Child content will inherit the path of the parent.
