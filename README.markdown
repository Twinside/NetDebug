NetDebug
========

![NetDebug screenshot](https://github.com/Twinside/NetDebug/raw/master/img/screen.png)

NetDebug is a tool to help debugging text network protocol, it provide an interactive communication (much like telnet) and a concept of snippet to ease repetitive test.

Snippets
--------
The snippets are for now just a simple json file editable from the file menu, and must be reloaded to be used.

For example, the snippet file used in the screenshot is the following :

    [ {"noop":"a000 NOOP\r\n"},
      {"authenticate":"A42 AUTHENTICATE gloubiAuth\r\n"}
      {"capability":"a002 CAPABILITY\r\n"},
      {"badlogin":"a0BAD LOGIN testuser wrongpass\r\n"},
      {"login":"a001 LOGIN testuser testpass\r\n"},
      {"logout":"A0010 LOGOUT\r\n"}
    ]

Building
--------
Load the project in xcode, build done. Alternatively you can use `xcodebuild` .

