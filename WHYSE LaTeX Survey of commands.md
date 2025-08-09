# GROUP ONE
This group was seen within paragraphing text (within a documentation chunk).

```latex
{\Tt{}\nwlinkedidentq{whyse}{NW43JrUv-4YCtgL-1}\nwendquote}
```

Reformatted, without arguments in the commands, it reads as follows.

```latex
{
    \Tt{}
    \nwlinkedidentq{}{}
    \nwendquote
}
```

Whether all paragraphing text references are like this remains to be seen.

Not all prosaic noweb macros are entirely composed of `nwlinkedidentq`:

```latex
{\Tt{}M-x{\char126}customize-group{\char126}\nwlinkedidentq{whyse}{NW43JrUv-4YCtgL-1}\nwendquote}
```

This time the reformatted group will not be stripped of command arguments.

```latex
{
    \Tt{}
    M-x{\char126}customize-group{\char126}
    \nwlinkedidentq{whyse}{NW43JrUv-4YCtgL-1}
    \nwendquote
}
```

The third and fourth groups (within the first) ensure that `\char126` is
interpreted as a single unit, inserting a character with that number.

`nwlinkedidentq` and `nwlinkedidentc` are commands which call internal macros appropriate to the selected package options.

**Options applicable to all identifiers:**
- subscriptidents;
- nosubscriptidents;
- hyperidents;
- nohyperidents;

**Options applicable only to identifiers appearing in quoted code:** 
- subscriptquotedidents;
- nosubscriptquotedidents;
- hyperquotedidents;
- nohyperquotedidents.

# GROUP TWO

There command `nwlinkedidentc` is markup for identifiers used *in code*:

```latex
\nwfilename{/var/home/bryce/Documents/src/whyse/src/whyse.nw}\nwbegincode{1}\sublabel{NW43JrUv-4YCtgL-1}\nwmargintag{{\nwtagstyle{}\subpageref{NW43JrUv-4YCtgL-1}}}\moddef{Customization and global variables~{\nwtagstyle{}\subpageref{NW43JrUv-4YCtgL-1}}}\endmoddef\nwstartdeflinemarkup\nwusesondefline{\\{NW43JrUv-4e7Hxw-3}}\nwprevnextdefs{\relax}{NW43JrUv-4YCtgL-2}\nwenddeflinemarkup
\nwindexdefn{\nwixident{whyse}}{whyse}{NW43JrUv-4YCtgL-1}(defgroup \nwlinkedidentc{whyse}{NW43JrUv-4YCtgL-1} nil
  "noWeb HYpertext System in Emacs"
  :tag "WHYSE"
  :group 'applications)

\nwindexdefn{\nwixident{w-registered-projects}}{w-registered-projects}{NW43JrUv-4YCtgL-1}(defcustom \nwlinkedidentc{w-registered-projects}{NW43JrUv-4YCtgL-1} nil
  "This variable stores all of the projects that are known to WHYSE."
  :group 'whyse
  :type '(repeat w--project-widget)
  :require 'widget
  :tag "WHYSE Registered Projects")

\nwalsodefined{\\{NW43JrUv-4YCtgL-2}\\{NW43JrUv-4YCtgL-3}}\nwused{\\{NW43JrUv-4e7Hxw-3}}\nwidentdefs{\\{{\nwixident{w-registered-projects}}{w-registered-projects}}\\{{\nwixident{whyse}}{whyse}}}\nwendcode{}\nwbegindocs{2}\nwdocspar
```

Reformatting this longer section, we have the following:


```latex
\nwfilename{/var/home/bryce/Documents/src/whyse/src/whyse.nw}
\nwbegincode{1}
\sublabel{NW43JrUv-4YCtgL-1}
\nwmargintag{
    {
        \nwtagstyle{}
        \subpageref{NW43JrUv-4YCtgL-1}
    }
}
\moddef{Customization and global variables~
    {
        \nwtagstyle{}
        \subpageref{NW43JrUv-4YCtgL-1}
    }
}
\endmoddef

\nwstartdeflinemarkup
    \nwusesondefline{\\{NW43JrUv-4e7Hxw-3}}
    \nwprevnextdefs{\relax}{NW43JrUv-4YCtgL-2}
\nwenddeflinemarkup
\nwindexdefn{\nwixident{whyse}}{whyse}{NW43JrUv-4YCtgL-1}% three arguments
(defgroup \nwlinkedidentc{whyse}{NW43JrUv-4YCtgL-1} nil
  "noWeb HYpertext System in Emacs"
  :tag "WHYSE"
  :group 'applications)

\nwindexdefn{\nwixident{w-registered-projects}}{w-registered-projects}{NW43JrUv-4YCtgL-1}
(defcustom \nwlinkedidentc{w-registered-projects}{NW43JrUv-4YCtgL-1} nil
  "This variable stores all of the projects that are known to WHYSE."
  :group 'whyse
  :type '(repeat w--project-widget)
  :require 'widget
  :tag "WHYSE Registered Projects")

\nwalsodefined{
    \\{NW43JrUv-4YCtgL-2}
    \\{NW43JrUv-4YCtgL-3}
}
\nwused{
    \\{NW43JrUv-4e7Hxw-3}
}
\nwidentdefs{
    \\{
        {\nwixident{w-registered-projects}}
        {w-registered-projects}
    }
    \\{
        {\nwixident{whyse}}{whyse}
    }
}
\nwendcode{}

\nwbegindocs{2}\nwdocspar
```

...and as formatted by **latexindent.pl**:

```latex
\nwfilename{/var/home/bryce/Documents/src/whyse/src/whyse.nw}
\nwbegincode{1}
\sublabel{NW43JrUv-4YCtgL-1}
\nwmargintag{
	{
		\nwtagstyle{}
		\subpageref{NW43JrUv-4YCtgL-1}
	}
}
\moddef{Customization and global variables~
	{
		\nwtagstyle{}
		\subpageref{NW43JrUv-4YCtgL-1}
	}
}
\endmoddef

\nwstartdeflinemarkup
\nwusesondefline{\\{NW43JrUv-4e7Hxw-3}}
\nwprevnextdefs{\relax}{NW43JrUv-4YCtgL-2}
\nwenddeflinemarkup
\nwindexdefn{\nwixident{whyse}}{whyse}{NW43JrUv-4YCtgL-1}% three arguments
(defgroup \nwlinkedidentc{whyse}{NW43JrUv-4YCtgL-1} nil
"noWeb HYpertext System in Emacs"
:tag "WHYSE"
:group 'applications)

\nwindexdefn{\nwixident{w-registered-projects}}{w-registered-projects}{NW43JrUv-4YCtgL-1}
(defcustom \nwlinkedidentc{w-registered-projects}{NW43JrUv-4YCtgL-1} nil
"This variable stores all of the projects that are known to WHYSE."
:group 'whyse
:type '(repeat w--project-widget)
:require 'widget
:tag "WHYSE Registered Projects")

\nwalsodefined{
	\\{NW43JrUv-4YCtgL-2}
\\{NW43JrUv-4YCtgL-3}
}
\nwused{
	\\{NW43JrUv-4e7Hxw-3}
}
\nwidentdefs{
	\\{
	{\nwixident{w-registered-projects}}
	{w-registered-projects}
}
\\{
{\nwixident{whyse}}{whyse}
}
}
\nwendcode{}

\nwbegindocs{2}\nwdocspar
```

Until a later time, I can simply forget about the `nwfilename` macro. I am working on the absolute basic support at the moment. I cannot think about multi-noweb file documents yet.

`nwbegincode` and `nwendcode` are environment specifying macros. It's fairly easy to understand that these must be paired properly. Exactly what they do is not a concern to me yet, I'm just noting that these are here and that they're mirrored commands. BEGIN. END. Simple, right?

`moddef` and `endmoddef` are likewise paired commands. (IMPLICITLY BEGIN)THING. ENDTHING. This is less simple.

`nwstartdeflinemarkup` and `nwenddeflinemarkup` are likewise a pair.

`nwindexdefn` is a command that defines a term to be indexed. It takes three arguments.

`nwlinkedidentc` is a cross-reference to an identifier. It takes two arguments.
