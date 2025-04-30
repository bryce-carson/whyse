(TeX-add-style-hook
 "knoweb"
 (lambda ()
   (TeX-run-style-hooks
    "calc"
    "mparhack")
   (TeX-add-symbols
    '("nwixlogsorted" 2)
    '("nwidentdefs" 1)
    '("nwixadd" 3)
    '("pendingsublabel" 1)
    '("nextchunklabel" 1)
    '("newsublabel" 2)
    '("nosublabel" 1)
    '("subpagepair" 1)
    '("subpageref" 1)
    '("subpages" 1)
    '("nwnextdefptr" 1)
    '("nwprevdefptr" 1)
    '("nwcodecomment" 1)
    '("eatline" 1)
    '("nwthepagenum" 2)
    '("nwmargintag" 1)
    '("nwixadds" 2)
    '("sublabel" 1)
    '("nwoutput" 1)
    '("nwbegindocs" 1)
    '("nwbegincode" 1)
    "nw"
    "nwendcode"
    "nwenddocs"
    "nowebchunks"
    "nowebindex"
    "other"
    "setupcode"
    "nwendquote"
    "nwnewline"
    "setupmodname"
    "LA"
    "RA"
    "plusendmoddef"
    "nwtagstyle"
    "Rm"
    "It"
    "Tt"
    "Bf"
    "nwcodepenalty"
    "code"
    "edoc"
    "nwtypesetcommentfont"
    "pending"
    "n"
    "nwindexdefn"
    "nwindexuse"
    "nwblindhyperanchor"
    "nwhyperreference"
    "nwanchorto"
    "nwbackslash"
    "nwlbrace"
    "nwrbrace"
    "nwdocspar"
    "nwmargintag"
    "nowebsize"
    "nwalsodefined"
    "nwused"
    "nwnotused"
    "nwprevnextdefs"
    "nwusesondefline"
    "nwstartdeflinemarkup"
    "nwenddeflinemarkup"
    "nwlinkedidentc"
    "nwlinkedidentq"
    "nwidentdefs"
    "nwidentuses"
    "nwixaddsx"
    "nwixadds"
    "chaptermark"
    "sectionmark"
    "subsectionmark"
    "subsubsectionmark"
    "paragraphmark"
    "subparagraphmark"
    "nwfilename"
    "d"
    "Btok"
    "thepage"
    "protect"
    "nwixd"
    "nwixu"
    "nwanchorname"
    "nwixident")
   (LaTeX-add-environments
    "webcode"
    "moddef"
    "nwtypesetcomment"
    "thenowebchunks"
    "thenowebindex")
   (LaTeX-add-pagestyles
    "noweb")
   (LaTeX-add-lengths
    "nwcodeindent"
    "nwcodetopsep"
    "nwbreakcodespace"
    "nwcodecommentsep")
   (LaTeX-add-saveboxes
    "nw"))
 :latex)

