![bash-static-blog-thumbnail](/src/assets/images/stable_difussion_abandoned_library.jpg)

# Bash static blog

A straightforward approach to generate a blog with static content from a markdown folder using a simple bash script execution.

Features:

- Converts markdown into HTML with syntax highlighting support, making it perfect for displaying code blocks
- Generate the list of articles automatically in the main `index.html`
- Copies the same path of the markdown to the `src` folder
- Includes a Docker environment with Nginx to serve the web content _(optional)_
- Provides an assistant to create new markdown files with front matter data using `create-markdown-file.sh`.
- Takes advantage of the template system of Pandoc to generate and translate new articles
- Easy to customize the HTML and CSS, with no theme system, just freely editable files

## Generate

Read the markdown files inside `content` folder and generate the html files in the `src`. Put a date in format `YYYY-MM-DD` to have them sorted in the index.

`2023-04-07-diablo3-loot-system-con-python.md` translates into `diablo3-loot-system-con-python.html`

```bash
bash generate.sh

Generated html from article 2023-04-11-funcionalidades-comunes-para-el-dia-a-dia-con-bash.md
Generated html from article 2023-04-07-diablo3-loot-system-con-python.md
Generated html from article 2023-04-04-blog-estatico-con-bash.md
Generated html from article 2023-03-23-leer-argumentos-en-tu-script-bash.md
```

## Create a new markdown file

Take advantage of the assistant to speed up the process to create a new empty markdown file filling the frontmatter data.

```bash
bash create-markdown-file.sh

Choose the author name for your new markdown file (default s3r0s4pi3ns):
Choose a filename for your new markdown file: my-fancy-content
Choose a frontmatter title for your new markdown file:
Choose a frontmatter description for your new markdown file: SEO is not my passion
Choose a header thumbnail for your new markdown file: (default path /assets/images): thumbnail.jpg
Choose a date (default 2023-04-16):

Created markdown file in /Users/s3r0s4pi3ns/Documents/pandoc-showcase/content/2023/2023-04-16-my-fancy-content.md

### 2023-04-16-my-fancy-content.md
---
author: s3r0s4pi3ns
date: 2023-04-16
human_date: 16 April, 2023
description: SEO is not my passion
title: 5 Tips to start in bash
path: blog/2023/my-fancy-content
thumbnail: /assets/images/thumbnail.jpg
---
###


```
