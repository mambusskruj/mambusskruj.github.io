---
title: 'Neovim as a markdown editor'
description: 'Using Neovim as a markdown editor'
date: 2024-02-11
draft: false
---

<!--toc:start-->
- [Introduction](#introduction)
- [Goals](#goals)
- [Synchronization](#synchronization)
- [Syntax highlights and conceals](#syntax-highlights-and-conceals)
- [Better spell checker](#better-spell-checker)
- [Navigation](#navigation)
- [Snippets](#snippets)
- [Render images in editor](#render-images-in-editor)
- [Viewing rendered document](#viewing-rendered-document)
- [A bit about performance](#a-bit-about-performance)
- [Things to improve](#things-to-improve)
- [Conclusion](#conclusion)
<!--toc:end-->

## Introduction

I am a Neovim user for 2 years. I'm also keyboard oriented user since then. Furthermore, I've built my working environment all around neovim as a core. I'm using DAP within Neovim to debug Python code, I'm writing drafts in Neovim for work-related tasks, and I'm using Neovim side by side in my terminal with shell session. I have a shortcut to access the terminal with an open Neovim instance. 

This week I've decided to write notes and longer posts about my life and work. Markdown seems like the best option for a text formatting system everyone knows and everyone understands both people and tools. Even unrendered markdown is pretty much readable. So I take it.

For a moment I was considering a specialized editor for that, like *Obsidian* or even *Evernote*. That's because I knew Neovim should be configured properly for a comfortable writing experience. At that point, I wanted to *just write formatted notes*.

**Evernote** seems like a mature future-proof engine for any kind of note. It has it all, not only text editor:
- Contains an integrated calendar and AI assistant;
- Has collaboration features;
- Can be paired with web clipper;
- Has integrations with many apps;
- Has synchronization, backups, and many more features;

As soon as I started digging into it, I understood that Evernote was not for me. Too complicated. So many features I don't want. Product lock-in.

**Obsidian** is a nice choice for sure for most users: 
- Markdown compatible;
- You own your data;
- You can use whatever tool for sync and backup;
- It's just an interface for changing and searching your notes;
- It even has built-in vim mode.

However, I realized I wanted a system that feels similar to the Personal Development Environment I use Neovim for. Like, I want to be at home when I write about things I'm interested in. I also don't want to overload myself with features.

So I decided to use tools I'm already familiar with: File-based structure, Git for sync, Neovim for editing, and browser for rendering (via Neovim plugin).

## Goals

After some research and reflections, I've formed what I want from the system:
- simple, obvious
- quickly reachable
- easy to use
- limitations (less is more)
- synchronization
- possibility to customize (I want my shortcuts, I want to disable unwanted things)
- portable, no lock-ins

This is when I feel the note-taking system is beautiful.

## Synchronization

I use a file system to categorize my notes. It allows me to use Git for synchronization. I pretty much acknowledged of Git, I've configured tools around it, and I'm ready to use it. It also makes synchronization cost free, because I only need a private repo in GitHub.

## Syntax highlights and conceals

Markdown syntax highlighting in Neovim is provided by [Neovim treesitter engine](https://github.com/nvim-treesitter/nvim-treesitter) and [markdown treesitter plugin](https://github.com/tree-sitter-grammars/tree-sitter-markdown). All you need is to add **markdown** and **markdown_inline** parsers to the treesitter configuration.

The thing that bothers me in the process of creating markdown notes in a simple text editor is syntax artifacts all around. Most pain I feel by adding a link to the block of text. Link syntax creates so much noise. Fortunately, there's a solution. Neovim (as well as Vim) provides [text concealing](https://neovim.io/doc/user/options.html#'conceallevel') as a core feature, which means we can hide format syntax and show it only when the cursor is placed on the line. 

All you need is to enable conceals in the Neovim config: `vim.opt.conceallevel = 2`

Treesitter provides nice concealing for most Markdown syntax:
- link
- image
- text style processing: bold, italic, strikethrough
- code
- footnote

How it looks:
![Conceals example](/images/conceals.png)

## Better spell checker

[LanguageTool](https://languagetool.org/)
 is a grammar tool and spell checker with an open-source core. I'm using the free tier and considering upgrading to a paid plan because I would like to improve my writing in English. LanguageTool can be used inside Neovim as a Language Server with [ltex-ls](https://github.com/valentjn/ltex-ls) plugin. Implementation has some limitations. You can't:
 - add a new word to the dictionary
 - hide false positive
 - disable rule

But you are still able to fix grammar and spelling.

Inability to add a new word to the dictionary bothered me. So I decided to glue [Vim's spell feature](https://neovim.io/doc/user/spell.html) and LanguageTool LSP. Here's how I did that:

```
local spell_words = {}
for word in io.open(vim.fn.stdpath("config") .. "/spell/en.utf-8.add", "r"):lines() do
    table.insert(spell_words, word)
end
                                                                                       
lsp_config.ltex.setup({
   settings = {
      ltex = {
         language = "en-US",
         enabled = true,
         dictionary = {
            ["en-US"] = spell_words,
        },
      },
   },
})
```

We can add new words with the "[zg](https://neovim.io/doc/user/spell.html#zg)" shortcut executed in normal mode when the cursor is placed on the file. 

The block of code collects all added words from the spellfile and propagates words as part of the dictionary for ltex LSP. The only downside is that you need to restart Neovim to see changes.

Note about path and name conventions
: Vim searches for spell files in the "spell" subdirectory in the config path. The name format of the spell file must be LL.EEE.add, where
  - LL the language name
  - EEE	the value of 'encoding'

## Navigation

[Marksman LSP](https://github.com/artempyanykh/marksman/) is a great companion for writing in Markdown. I find it useful for:
- Document symbols from headings, so I can find and navigate through headings easily;
- Completion for links, even links to the different files;
- "Go to definition" for links, so I can jump everywhere, even in other files;
- Rename, so I can update the header name in all places it was referenced;
- Generate a table of contents.

You can find more features (and plans too) in [Marksman's docs](https://github.com/artempyanykh/marksman/blob/main/docs/features.md).

This is how I search headings with Marksman and Telescope:
![Navigation example](/images/navogation.png)

## Snippets

Writing Markdown without snippets is hard. Especially if you like to add a bunch of images and links. Snippets allow me to write faster using fewer keystrokes. I use [LuaSnip](https://github.com/L3MON4D3/LuaSnip/) as a snippet engine, and [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) for autocomplete integration with [autocompletion engine](https://github.com/hrsh7th/nvim-cmp). LuaSnip documentation suggests to use predefined snippets from various sources ([1](https://github.com/honza/vim-snippets/tree/master/snippets), [2](https://github.com/rafamadriz/friendly-snippets/tree/main/snippets)) or write your own. For the latter, you have two choices: 
- use SnipMate/VS Code snippets (easier)
- write snippets in Lua (more complex but also more feature-rich). 

As I needed a few simple snippets, I decided to copy some existing ones from [honza's markdown snippets](https://github.com/honza/vim-snippets/blob/master/snippets/markdown.snippets).

What I have so far:

```
# The suffix `c` stands for "Clipboard".

# LINKS
snippet [
	[${1:text}](https://${2:address})

## url from clipboard
snippet [c
	[${1:link}](${2:`@+`})


# FRONTMATTER (for metadata)
snippet -- Front matter
	---
	$0
	---


# TODO
snippet xx
	- [ ] ${1:todo}


# IMAGES
snippet ![
	![${1:alttext}](${2:/images/image.jpg})

snippet ![c
	![${1:alt}](${2:`@+`})


# CODE
snippet ```l
	\`\`\`${1:language}
	${2:code}
	\`\`\`


# TABLE
snippet tb
	|  ${0:factors}      |    ${1:a}       |  ${2:b}   	|
	| ------------- |-------------  | ------- |
	|    ${3:f1}    |    Y          | N       |
	|    ${4:f2}    |    Y          | N       |


# DEFITION LIST
snippet : Definition list
	$1
	: $0

snippet :: Alternate definition list
	$1
	  - $0
```

It's not much, but I have everything I need. Additionally, the small amount of snippets doesn't overfill the autocompletion pop-up with suggestions.

## Render images in editor

*Promising start, unfortunate end.*

Aside from text, I would like to have images in my posts. Images add fun, create associations, and make the post rich. Adding images in Markdown is as easy as adding links. You can also add height and width for images.

Still, you have to render documents, to view images. I wanted to go deeper and preview images while I was typing text, right in the Neovim. I also wanted to add images from the clipboard easily. With Kitty graphic protocol and a few neovim plugins, we can achieve it.

[Kitty's terminal graphic protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/) creates a flexible and performant protocol that allows the program running in the terminal to render arbitrary pixel (raster) graphics to the screen of the terminal emulator. Which basically means we can view images in the editor.

By the way, [WezTerm](https://github.com/wez/wezterm/issues/986), [Konsole](https://invent.kde.org/utilities/konsole/-/merge_requests/594), and [wayst](https://github.com/91861/wayst) terminal emulators have implemented kitty's graphic protocol as well.

Then we need plugins:
- [image.nvim](https://github.com/3rd/image.nvim) for image rendering in Neovim buffer;
- [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim) for pasting images from clipboard.

Everything was fine until I started to write long sentences and Neovim started to wrap my text. The image plugin (image.nvim) can't measure the rendered height of a buffer section. 

So if you have wrapped text, your placed images in the text start to look like this:
![Image rendering with wrapped text](/images/image-render-with-wrapped-text.png)
[There's an issue on the plugin's GitHub page](https://github.com/3rd/image.nvim/issues/116), but it can't be fixed on the plugin side because of Neovim limitations. This was a dealbreaker for me, so I decided to drop the image rendering feature within the editor.

## Viewing rendered document

For this part, I've decided to go simple. I use popular Vim/Neovim plugin [markdown-preview](https://github.com/iamcco/markdown-preview.nvim) to convert Markdown into HTML and view the result in the browser with `:MarkdownPreview` command. My typical writing experience is based on a split fullscreen containing terminal+Neovim and browser tab with converted and rendered Markdown.

![Showcase-writing](/images/2024-03-10-10-56-45.png)

Simple, yet powerful.

## A bit about performance

By installing plugins we're increasing Neovim startup time. This is how big the overhead is for cold start opening Markdown file. Need to say startup time is a bit different in every measure, but I can say the increase is in the **200-300ms** range.

```
Command: nvim --startuptime

@:~$ cat startuptime-markdown-file.log | tail -n 2
649.335  000.004: --- NVIM STARTED ---

@:~$ cat startuptime.log | tail -n 2
407.371  000.001: --- NVIM STARTED ---
```

## Things to improve

I still have some caveats with the Markdown text environment. It's not ideal and has a room to improve.

For example, I would like to manipulate lists in a better way. Being in the list and pressing Enter **twice** should automatically create a new list item on a new line and then delete it. I know Markdown plugins provide something similar, but they don't work as expected. Maybe one day I will write simple automation by myself.

I also would like to integrate AI to assist with editing and rephrasing because, as you may already have noticed, my English is not good enough to write nice texts. 

## Conclusion

In this article, I've shared personal thoughts about preferences and choices for the note-taking system and showed the writing environment I've come to. I hope someone will find it helpful. Thank you all.
