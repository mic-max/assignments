==========================================================
WindowBuilder Pro 3.1 for VisualSmalltalk 3.1 for Windows.
Release Date: December 15, 1995.
==========================================================

Welcome to WindowBuilder Pro/VST 3.1 for Windows 3.1, Windows 
95 and Windows NT!  We at Objectshare would like to thank you 
for your purchase.  We're sure that WindowBuilder Pro will be a 
useful tool for you in building VisualSmalltalk applications.

This README file covers several topics not covered in the 
installation guide or the manual, as well as information that 
was added after the manual was printed.  It includes 
information on:

  o Whats New
  o Installation Instructions
  o Installer Notes
  o Team/V Installation Instructions
  o Manual Addendum
    - OCX/OLE Support
  o New Digitalk Event Model
  o Porting from ST/V 2.0 to VST 3.1
  o Event Translation Utility
  o Hints for WindowBuilder Standard users      
  o Creating Runtime Applications
  o Tips for creating runtime-less applications
  o Using WindowBuilder with MDI  
  o Packing list
  o Note on Bitmap DLLs
  o Other Notes
  o General Note on Tech Support
  o OSI's Support Policy


WHAT'S NEW
==========

  o Support for VisualSmalltalk 3.1
  o New editing kernel with new layout widget and geometry manager
  o Unlimited undo/redo with Undo/Redo dialog
  o Template editor for customizing widget defaults
  o Powerful pool dictionary management
  o Enhanced font handling and code generation
  o Extensive NLS support with string extraction and replacement
  o New Bitmap Manager with .RC file generation
  o New Event Manager for creating and editing event handlers
  o Extensive support for domain model objects (SharedValues, Timers, etc.)
  o New Model Definition Wizard for creating EventManager subclasses
  o New Layout Wizard for automatically creating screens
  o New Tab Order Editor with drag drop and automatic tab order definition
  o Dynamic look policy switching - preview window in Win31, Win95 or OS/2 looks
  o New Property Manager for customizing WindowBuilder Pro itself
  o Improved status line help with current time
  o Ability to display z-order of widgets in the editing window
  o Widgets in editor can be dragged as outlines or "live"
  o Optional Tools menu with power user features
  o Supports LayoutFrames as the default framing mechanism
  o New Framing Editor with framing style toolbar and improved thumbnail view
  o #createView method has zero WindowBuilder Pro runtime dependencies
  o Enhanced ApplicationCoordinator support
  o Style combobox now targets multiple widgets
  o New manual with cookbook of common (and not so common) GUI tasks
  o Support for Windows 95 common controls
  o Support for OCX controls under Windows 95


INSTALLATION INSTRUCTIONS
=========================

NOTE: If you are using Team/V and would like to load 
    WindowBuilder Pro from a PVCS repository rather than from 
    SLLs, read the section titled "Team/V Installation 
    Instructions" below.

NOTE: If you are migrating WindowBuilder Pro generated code 
    from V/Win16 2.0, you *MUST* load Digitalk's obsolete support 
    (see 5c below). If you do not do this, your windows will not 
    run under VST 3.1 and WindowBuilder Pro will not be able to 
    load and convert them properly. After you have migrated your 
    windows to using standard VST 3.1 conventions (e.g., the new 
    event model), you can remove (unbind) the Digitalk and 
    WindowBuilder Pro obsolete support. 

NOTE: To install WindowBuilder Pro, MDI, and Subpanes, do them 
    in the following order:  

    1) MDI
    2) WindowBuilder Pro
    3) Subpanes/V   

MDI is a feature of VisualSmalltalk 3.1 for Win32.  It is 
provided in an .SLL file that comes with the VisualSmalltalk 
installation.  For more information on MDI, see the file 
31extras.txt in the \DOC subdirectory of the Digitalk release 
directory.

NOTE: Anywhere that "\VSW31" appears, VisualSmalltalk 
    Enterprise users should use "\VSEW31"

To install WindowBuilder Pro:

1)  Check your disk space.  The total required for WindowBuilder 
    Pro installation is 5.8 Mb.

2)  Run SETUP.EXE off of Installation Disk #1 (e.g,
    A:\SETUP.EXE). This will create a directory for you and 
    decompress all of the WindowBuilder Pro source files. (The 
    default WindowBuilder Pro directory is \WBPW31).

    Make sure that you properly record your name and serial 
    number when asked.  If you fail to do this, we will be 
    unable to provide you with support.

3)  Either:

    * Add the WindowBuilder Pro directory (e.g. \WBPW31) to 
      your PATH

    -- or --

    * Copy all of the WindowBuilder Pro source files (.SLL, 
      .SML, .SBK, .ICO, .PAR & .DLL) from your WindowBuilder 
      Pro directory (e.g. \WBPW31) to your Smalltalk library 
      directory (e.g. \VSW31\LIB).

4)  Make sure VisualSmalltalk 3.1 is properly installed, and 
    that a clean V.EXE image file is in your Smalltalk 
    development directory (e.g. \VSW31). The V.EXE file in 
    this directory is the image in which WindowBuilder Pro will 
    be installed.

    Be sure also that the Smalltalk/V Win32 startup program 
    VDEVW.EXE is in this directory, and that the Smalltalk 
    library directory (e.g. \VSW31\LIB) is in the PATH.

5)  Optional: Install Digitalk EXTRAS. All of the extras may be 
    installed via the Browse Services option under the Smalltalk 
    menu.

    a. We strongly suggest that you install Digitalk's 
       StatusPane support before installing WindowBuilder Pro.  
       If you have PARTS Workbench installed, the StatusPane 
       class will already be installed.

    b. We strongly suggest that you install Digitalk's 
       ObjectFiler before installing WindowBuilder Pro.

    c. If you are upgrading from an old version of 
       WindowBuilder Pro, and have existing code that you want 
       to port to the new Smalltalk, then install the Digitalk 
       Obsolete Support.

    d. Digitalk's MDI support may also be used in conjunction 
       with WindowBuilder Pro.

6)  Launch the VisualSmalltalk 3.1 image into which you wish 
    to install WindowBuilder Pro.

7)  Select the Install... command from the File menu.  Select 
    the file INSTALL.WB, and press the OK button.  The 
    installation process will begin. When installation 
    completes, the "About WindowBuilder Pro" dialog should 
    appear.  If you encounter any problems during the 
    installation process, contact us at (408) 970-7280.

8)  When installation is completed, save your image.  If you 
    have the disk space to spare, it is a good idea at this 
    point to make a backup of the current image (which consists 
    of the files V.EXE and CHANGE.LOG), so that you can easily 
    return to a clean image containing WindowBuilder Pro when 
    starting new projects.

9)  Next, you should read through the manual and tutorial to 
    get familiar with WindowBuilder Pro.


INSTALLER NOTES
===============

This installer is designed to allow you to customize your 
installation, while maintaining the correct dependencies. When 
you select a library, the comment field at the bottom lists 
the classes it contains or its function.

When you open the installer, those libraries already installed 
are shown in light gray with a check mark.  Libraries that are 
not installed are shown in black.  A check mark beside the name 
indicates that it will be installed if you press the 'Install' 
button.  If you press the 'Script' button, a window opens with 
a script that can be executed to install the libraries that are 
checked.  If Team/V is installed in your image, the script is 
Team-enabled; otherwise, it is in plain file-in format.

You can re-open the installer to install additional libraries 
by re-installing the INSTALL.WB file.


TEAM/V INSTALLATION INSTRUCTIONS
================================

The normal WindowBuilder Pro installation process described 
above will correctly install WindowBuilder Pro regardless of 
whether Team/V is installed. If Team/V is installed, we have 
provided an additional option of loading WindowBuilder Pro from 
a PVCS repository. To install WindowBuilder Pro this way, do 
the following:

1)  Perform steps #1 - #3 in the standard installation 
    instructions above.

2)  Copy the file, WBP31TMW.ZIP, from Installation Disk #3 to 
    your hard disk.

3)  Unzip the file while preserving its subdirectory structure. From
    a DOS prompt, use the following command:

       PKUNZIP WBP31TMW.ZIP -d

    This will create the following directory structure:

       .\WBP31TMW

4)  Launch your VisualSmalltalk Enterprise image with Team/V and
    PARTS Workbench loaded (Note that in order to load the 
    WindowBuilder Pro repository, PARTS *must* be loaded first).

5)  Open the Inclusion Context editor via the "Smalltalk | Browse |
    Inclusion Context" command. Add an inclusion context called
    "win32" and click OK. You may optionally define an inclusion
    context called "obsolete". This will load WindowBuilder Pro 
    obsolete runtime packages. Adding an "mdi" inclusion context 
    will cause the WindowBuilder Pro MDI support to be loaded as
    well (MDI must be loaded first). Adding an "examples" 
    inclusion context will cause the WindowBuilder Pro examples 
    to be loaded. Adding an "ole" inclusion context will load the
    WindowBuilder Pro OLE Support package. In order for OLE support
    to properly load, you need to bind all of PP-D's OLE support
    libraries (the easiest way to do this is to launch PARTS
    Workbench and drop an OLEControlPart into the Workbench).

6)  Open the Repositories Browser via the "Smalltalk | Browse |
    Repositories" command. Connect to the WBP31TMW library.

7)  From a Package Browser, load the "WindowBuilder Pro" module 
    (cluster) revision "3.1" from the "WindowBuilder Pro 3.1 
    Win32" repository.

8)  Save your image.


MANUAL ADDENDUM
===============

As we constantly try to improve our product and push the limits 
on functionality, new features are added to the base system 
that are not reflected in the documentation. 

OCX/OLE Support
---------------

WindowBuilder Pro supports OCX controls under Windows 95. The 
base VisualSmalltalk product (sans PARTS) provides two OCX/OLE 
specific widgets - OLEClientSitePane and OLEControlSitePane. 
Unfortunately, both are extremely cumbersome to use and not 
very useful from WindowBuilder Pro's point of view. As part of 
its PARTS specific support, VisualSmalltalk also provides a 
widget called OLEControlPart that is well implemented and much 
more straightforward to use. We have chosen to wrapper this 
widget for use with WindowBuilder Pro. The upside is that this 
control is very easy to use. The downside is that you must have 
PARTS Workbench loaded in your image to make use of it. We 
intend to work closely with PP-D to correct the limitations 
with the base image OLE support components in the future.

To enable OLE support in WindowBuilder Pro, enable the "OLE 
Support" Add-In via the WindowBuilder Pro Add-In Manager. This 
will add an the OLEControlPart to the WindowBuilder Pro palette 
(at the bottom of the miscellaneous category). To use the 
control, drop an instance of it into the WindowBuilder Pro main 
editing window just as you would with any other widget. 
Initially, the widet will appear as an empty rectangle with the 
word "OLEControlPart" in the upper left corner. Double click on 
the widget to open the OLEControlPart attribute editor.

The "Change OLE Control" button allows you to select any of the 
OCX widgets installed on your system. WindowBuilder Pro will 
work with any of the OCX controls that will work with PARTS. 
There are some OCXes that are not well behaved that will not 
work well with VisualSmalltalk (PP-D provides a list of some of 
these). If you are having a problem with a specifix OCX and you 
suspect a WindowBuilder Pro problem, please try the control in 
PARTS Workbench as well to see whether it is a general 
incompatibility between the OCX and VisualSmalltalk. Once you 
have selected a control, it will appear in the large pane 
filling the center of the screen.

Once the OCX has been selected, you may use the "Control 
Properties" button to open the property dialog specific to that 
OCX (these dialogs are built into the OCX itself and are not 
part of WindowBuilder Pro).

Two inspect buttons are provided for inspecting the OCX contol 
and its internal structures. At the bottom of the dialog, three 
buttons are provided for viewing the public protocols (Methods, 
Properties and Events) supported by the selected OCX. The 
contents of these windows may be saved as text files for later 
viewing.

Once you have specified the OCX control and established its 
initial properties, click OK to return to WindowBuilder Pro. 
The OLEControlPart representation in WindowBuilder Pro will now 
show the name of the specific OCX control as well as its server 
location (path and file name). Once the OCX has been selected, 
the event list in the When: combobox will also list the OCX 
specific events supported by the control. These events are 
distiguishable from the normal Smalltalk events by the fact 
that they are all capitalized. Please refer to the 
documentation for the OCX control to determine what the events 
are used for and what the arguments that are passed represent.

When WindowBuilder Pro generates code for the OCX control, two 
pieces of information are written into the #createViews method. 
The argument to #clsid: is a unique identifier that represents 
the type of OCX control. The argument to 
#setPersistentStateStream: is a byte array representing the 
state of the OCX control (assuming that you established one 
using the "Control Properties" button in the attribute editor).


NEW DIGITALK EVENT MODEL
========================

WindowBuilder Pro for VisualSmalltalk fully supports 
Digitalk's new event model. When specifying a selector for a 
new event, use colons in the selector to specify where 
arguments should be.  If you add one more argument in your 
selector that the event selector expects, then that last 
argument will be the pane in which the event was triggered. 

By default, the target (reciever) of any event handler is 
'self' (e.g., the ViewManager itself). With the new event 
model, WindowBuilder Pro can generate event handlers that 
target additional entities. Specifically, valid targets include 
'self', the TopPane in which the pane resides, the pane itself, 
any widget in the window, any instance variable of the class 
(e.g., a ViewManager could define an instance variable named 
'model' and use that as the target of any triggered events), 
any WBPro-generated window class, or any global defined in the 
global Smalltalk dictionary. To set the target, right mouse 
click on the 'Send' entryfield. This will popup a menu from 
which you can select a target. The current target will be 
indicated via a checkmark. If you do not specify a target, 
'self' is used by default. Note that target selection is only 
valid in the context of the new event model. The old event 
model will only support 'self' as a valid target (old event 
model events are designated with an "(old)" appended to their 
names in the "When:" combobox. The popup target definition menu 
makes code like the following very easy to generate:

    launchButton
        when: #clicked send: #open to: MyViewManagerClass

Callback methods will only be generated for events that are 
configured to target 'self' (WindowBuilder Pro will not 
generate code into any other class except the current window 
class). When defining event handlers that target other 
entities, make sure that those other entities support the 
methods that you are invoking. If you configure events to 
target one of the ViewManager's instance variables, it is 
important to make sure that that instance variable is properly 
initialized before the ViewManager's #createViews method is 
executed (otherwise, the events will be configured to target 
'nil'). You can do this by creating an #initialize or #openOn: 
method for your ViewManager that properly initializes any 
needed instance variables.


PORTING FROM ST/V 2.0 TO VST 3.1
================================

The process of porting to VST involves two major steps:

1) Tracking down and eliminating obsolete code references 

2) Migrating to the new event model (current V/Win32 users may 
   already have done this)

The following script should help anyone who wants to track down 
obsolete code references in their classes. This is of primary 
importance to V/OS2 users moving to VST 3.1. We have used this 
script (and variations thereof) to track down and eliminate any 
obsolete code references in WBPro in the course of porting it 
to VST. 

| classes methods senders |

"Specify your classes here"
classes := (OrderedCollection new
        add: <Your Class Here>;
        add: <etc>;
        yourself).

methods := (((SmalltalkLibraryBinder contentsOf: 'VOBS31W') at: 'methods')
    collect: [:string | string copyFrom: (string indexOf: $>) + 2 to: string size])
    asSet asSortedCollection asArray collect: [:string | string asSymbol].

CursorManager execute changeFor: [
    methods do: [:aSymbol |
        senders := OrderedCollection new.
        classes do: [ :class |
            senders addAll: (class sendersOf: aSymbol)].
        senders isEmpty
            ifFalse: [
                MethodBrowser new
                    label: 'Obsolete Senders of: ', aSymbol;
                    literal: aSymbol;
                    openOn: senders]]].

The script will open a browser on each method in the Digitalk 
obsolete SLL (you need to bind it to your image) and show you 
senders of that method in whichever classes you are interested 
in. Many of the senders will be bogus because some of the 
obsolete methods share the same name as valid methods in other 
classes - you just need to wade through them.

You should be selective as to your target classes in order to 
avoid opening *lots* of method browsers and running out of 
memory in the process (e.g., having the system look at Object 
would be a bad idea). Try it with one or two of your 
ViewManager classes to get a feel for what it will show you. 

The hardest part of process in eliminating obsolete references 
will be in converting #when:perform:s to #when:send:to:s. We 
have found that to be a fairly mechanical process (and 
tedious). Every event in the old event model has an analog in 
the new event model (usually with the same name, although there 
are a number of exceptions that you need to be aware of). The 
biggest change is that the arguments that are passed to event 
handlers are very different than in the #when:perform: world.

Here are a few useful examples:

1) A standard button handler:

        when: #clicked perform: #ok:;

        ok: aPane
            self close

    becomes:

        when: #clicked send: #ok to: self;

        ok
            self close

2) A standard checkbox handler:

        when: #clicked perform: #setMyBoolean:;

        setMyBoolean: aPane
            myBoolean := aPane selection

    becomes:

        when: #clicked: send: #setMyBoolean: to: self;

        setMyBoolean: aBoolean
            myBoolean := aBoolean

3) A standard radiobutton handler:

        when: #clicked perform: #setMyChoice:;

        setMyChoice: aPane
            setMyChoice := self doSomething

    becomes:

        when: #turnedOn send: #setMyChoice to: self;

        setMyChoice
            setMyChoice := self doSomething

4) A standard list select handler:

        when: #select perform: #doSelect:;

        doSelect: aPane
            mySelection := aPane selectedItem

    becomes:

        when: #clicked: send: #doSelect: to: self;

        doSelect: selectedItem
            mySelection := selectedItem

5) A standard combobox select handler:

        when: #select perform: #doSelect:;

        doSelect: aPane
            mySelection := aPane selectedItem

    becomes:

        when: #changed: send: #doSelect: to: self;

        doSelect: selectedItem
            mySelection := selectedItem

6) A standard #getContents handler:

        when: #getContents perform: #getListContents:;

        getListContents: aPane
            aPane contents: #('A' 'B' 'C' 'D')

    becomes:

        when: #needsContents send: #getListContents: to: self withArgument: aListBox;

        getListContents: aPane
            aPane contents: #('A' 'B' 'C' 'D')

Note to V/Win16 Users
---------------------

Porting applications from V/Win 2.0 to VST 3.1 should be very 
easy. The only exception are fonts defined using non-portable 
font code generation. Fonts defined as byte arrays using the 
Font>>fromBytes: will transfer over as the System Font. 
WindowBuilder Pro provides two alternative font code generation 
techniques: portable and less accurate, or non-portable and 
more accurate. These are contained in the Font methods 
#portableStoreOn:indentString: and 
#nonPortableStoreOn:indentString:. By default the 
Font>>storeOn:indentString: method uses the non-portable code 
generation. Renaming Font>>portableStoreOn:indentString: to 
Font>>storeOn:indentString: will change the default code 
generation mechanism. Opening and resaving your ViewManager 
definitions after making this change will result in font 
definitions that will port to V/Win32.

The Window>>paneName and Window>>paneName: methods have been 
unified with Digitalk's pane naming mechanism. The name that 
you specify for a pane in WindowBuilder Pro will be the name 
used to locate the pane via the #paneNamed: method as well as 
the name used as a help topic key and as the name used with the 
#changed: mechanism. Unifying the naming mechanisms allows you 
to write code such as:

    self changed: 'paneName'

rather than:

    self changed: #getContentsSelector


EVENT TRANSLATION UTILITY
=========================

This utility facilitate translating the #createViews method.  
The WBTranslator class is a generic WindowBuilder translator, 
which will load the #createViews method of a class, perform 
some predefined translation on it, then regenerate the 
#createViews method.

The WBEventTranslator is a subclass of the generic WBTranslator 
class and provides translation of old Digitalk events to new 
Digitalk events within the #createViews method.

To translate:

    WBEventTranslator translate

or

    WBEventTranslator
        translate: <myViewMgrSubClass>

opens a window with a multi select list box so that you can 
choose which classes you would like to translate.  Double 
clicking on a class selects all of its subclasses.

To edit the event mappings:

    WBEventTranslator editEvents

When editing the event translation, class names appear in the 
upper left list box, old to new event mappings appear in the 
lower left list box, and new events appear in the right list 
box.  Select the desired class in the upper left list box and 
the old to new event mappings should appear in the lower left 
list box.  Old events mapped to new events appear as 

    oldEventName ==> newEventName

Old events that are mapped to new events in a class are 
inherited by all subclasses.  Thus if you have 'Button' 
selected in the upper left list box, you might see

    display ==> display [SubPane]

in the lower left list box, indicating that the old to new 
event mapping of #display to #display is inherited from SubPane.

Old events that are not mapped appear as 

    oldEventName

You can change the old to event mapping by selecting one of the 
old events in the lower left list box, then selecting the 
desired new event in the right list box.

If you would like to perform some other type of translation, 
subclass the WBTranslator class and override the #translate 
method to perform the desired translation.


HINTS FOR WINDOWBUILDER STANDARD USERS
======================================

WindowBuilder Pro provides numerous enhancements over the 
standard version of WindowBuilder. All of these are fully 
covered in the manual that accompanies the product.

The only important item to be aware of when moving to 
WindowBuilder Pro is that it generates #createViews methods by 
default rather that #open methods. This changes affords you a 
great deal of flexibility than the old approach. A #createViews 
method is exactly the same as the old #open method with the 
"self openWindow" line removed from the bottom. We have 
provided a standard #open method at the ViewManager level. You 
will still open windows the same way you always have (e.g., 
XYZWindow new open). In addition, we have also provided several 
other useful ViewManager methods including #openWithParent:. 
Any window can be opened independently (with the #open method) 
or as a child (using the #openWithParent: method).


CREATING RUNTIME APPLICATIONS
=============================

To create a runtime application, you should create an image 
that contains only your classes and methods;  WindowBuilder Pro 
itself should not be in the image. This not only helps satisfy 
WindowBuilder Pro licensing restrictions, but will reduce your 
image size as well.

The code that WindowBuilder Pro generates does not require any 
elements of the WindowBuilder Pro runtime. However, if you have 
utilized any of WindowBuilder Pro's optional pieces or 
facilities, you will need to include one or more elements of 
the runtime.

The files that constitute the WindowBuilder Pro runtime support 
are listed below. The runtime support code has been factored 
into several small pieces that may be loaded independently. The 
following is an example of the code that you would need to add 
to your .BND file to bind the runtime files dynamically:

; Install WindowBuilder Pro 3.1 Runtime for Win32
WB31RBW         ;WindowBuilder Pro 3.1 Runtime Base for Win32
WB31RBMW        ;WindowBuilder Pro 3.1 Runtime Bitmap Manager
WB31REFW        ;WindowBuilder Pro 3.1 Runtime EnhancedEntryField
WB31RMW         ;WindowBuilder Pro 3.1 Runtime Miscellaneous
WB31RCPW        ;WindowBuilder Pro 3.1 Runtime CompositePane
WB31RTBW        ;WindowBuilder Pro 3.1 Runtime ToolBar
WB31RFXW        ;WindowBuilder Pro 3.1 Runtime Base Image Fixes
WB31ROPW        ;WindowBuilder Pro 3.1 Runtime Base Image Optimizations
WB31RPMW        ;WindowBuilder Pro 3.1 Runtime Pool Manager

; If WindowBuilder Pro 2.0 runtime support is required, install:
; WB31R20W    ;WindowBuilder Pro 2.0 Runtime Support (FramingParameters)
; If PARTS Support is required, install:
; WB31RPW    ;WindowBuilder Pro 3.1 Runtime PARTS Support for Win32
; If LinkButton or ActionButton support is required, install:
; WB31RALW    ;WindowBuilder Pro 3.1 Runtime Obsolete for Win32
; If obsolete code support is required, install:
; WB31ROBW    ;WindowBuilder Pro 3.1 Runtime Obsolete for Win32
; If StatusPane support is required install:
; WB31RSTW    ;WindowBuilder Pro 3.1 Runtime StatusPane Support for Win32
; If MDI support is required install:
; WB31MDI     ;WindowBuilder Pro 3.1 Runtime MDI Support for Win32
; If Windows 95 widget support is required install:
; WB31R95W    ;WindowBuilder Pro 3.1 Runtime Windows 95 Support for Win32

WindowBuilder Pro code runs on both Windows and OS/2. If you 
purchase WindowBuilder Pro for OS/2, you will be able to easily 
port your code to that platform.


TIPS FOR CREATING RUNTIME-LESS APPLICATIONS
===========================================

If necessary, it is possible to for WindowBuilder Pro to 
generate code that has no dependencies on the WindowBuilder Pro 
runtime. This is a very useful feature for 3rd party tool 
providers who want to generate their interfaces but who do not 
want to deliver the WindowBuilder Pro runtime. It is also a 
useful feature for generating test cases for ParcPlace-Digitalk 
support that can be filed into a clean, non-WindowBuilder Pro 
image. The basic rule is to avoid anything that is 
WindowBuilder Pro specific. 

Do not use:

o EnhancedEntryField, WBToolBar, WBComboBox and WBStaticGraphic
o ActionButton and LinkButton (obsolete anyway)
o Any other non-base (or non-PP-D) widgets
o CompositePanes
o FramingParameters - WBPro 3.1 uses LayoutFrames by default
o self paneNamed: <widgetName> - assign widgets directly to 
  instVars instead. 
o Bitmap, Font or NLS pool support. You may still NLSize you 
  application, but you must manage the NLS pools manually.
o All WindowBuilder Pro alternative #open protocols 
  (e.g., #openWithParent:)
o Menu items with non-alphanumeric accelerators
o #preInitWindow and #initWindow - use the TopPane #validated 
  event instead
o WindowBuilder Pro MDI support
o Button #cancelPushButton style. Make sure to turn off the
  "Autorecognize OK and Cancel" property.
o DrawnButton #invisible style
o StatusPane #leftJustifiedFixed & #rightJustifiedFixed style
o Non-portable font code generation
o Optional n+1 event arguments (e.g., #when:send:to:withArgument:)
o Color paleGray (use Color gray instead)
o WB-PARTS support
o WBWindowDialog & WBDialogTopPane


USING WINDOWBUILDER PRO WITH MDI
================================

IMPORTANT: This section requires that you have an understanding 
of the MDI capabilities provided in VisualSmalltalk 3.1.  
Before reading it you should read the file 31extras.txt in the 
\DOC directory.

Any window created with WindowBuilder Pro's default code 
generation (#createViews) may be opened as an MDI parent by 
sending it the #openAsMDIParent message. Any window may be 
opened as an MDI child by sending it the #openWithMDIParent: 
message with a single argument, the MDI parent window. The 
following example will open a sample window as an MDI parent 
and then open another copy of it as an MDI child of the first:

    | test |
    test := TestWindow new openAsMDIParent.
    TestWindow new openWithMDIParent: test.

If a window must always open as an MDI parent, create a 
#topPaneClass method for the window that returns 'MDIFrame':

    topPaneClass
        ^MDIFrame

The WBToolBar class has been extended to provide an #mdiToolBar 
style. MDI toolbars are locked to the top of the window. The 
MDI StatusPane control has also been completely wrappered (they 
are locked to the bottom of the window). Multiple StatusBoxes 
may be easily created within the StatusPane.

CompositePanes have been extended with #mdiToolBar and 
#mdiToolBarBordered styles as well. With this new ability, 
toolbars similar to those found in Microsoft Word can be built.


WINDOWBUILDER PRO PACKING LIST  
==============================

*.SLL           Smalltalk Link Library files 
*.SML           Smalltalk source files 
*.ICO           Icon files
INSTALL.WB      WindowBuilder Pro installation script 
READMEWB.TXT    WindowBuilder Pro readme (this file)

WB31USRW.SBK    WindowBuilder Pro example scrapbook
WB31USRW.BPL    WindowBuilder Pro example bitmap pool defintion
WB31SYSW.*      WindowBuilder Pro system bitmaps
WB31USRW.*      WindowBuilder Pro example bitmaps
WB31BLDW.LOG    WindowBuilder Pro SLL Build Log


NOTE ON BITMAP DLLS
===================

We provide two versions of the WindowBuilder Pro bitmap DLLs. 
The primary versions, WB31SYSW.DLL and WB31USRW.DLL, are 
composed of 4-bit bitmaps. Some video adapters may be incapable 
of loading 4-bit bitmaps from DLLs. If this happens, you will 
either get an error in loading the bitmaps or the bitmaps may 
appear to be entirely black. The files WB31SYSW.8BT and 
WB31USRW.8BT contains the exact same bitmaps in 8-bit format. 
Simple rename WB31SYSW.8BT to WB31SYSW.DLL and WB31USRW.8BT to 
WB31USRW.DLL and replace the original 4-bit versions on your 
path. Restarting your image should then cause the 8-bit 
versions to be loaded. 

Both the .DLL and .8BT versions of the files are 32-bit 
resource DLLs. If neither of the 32-bit versions will work for 
you, contact your hardware provider as this indicates a 
hardware or video driver problem.


OTHER NOTES
===========

Initial Tab Order 
-----------------

When creating windows, there is no initial tab order. You must 
use the tabbing/grouping editor to create a tabbing order for 
tabbing between components to work.           

Closing Unwanted Dialogs
------------------------

At times, you may create a dialog that has no closebox, and in 
the process of testing it within WindowBuilder Pro, find that 
there is no way to remove either the dialog or WindowBuilder 
Pro.  If this ever happens, you can access your window as 
follows:

  MyDialogClassName allInstances do: [:each | each close].   

The dialog will close, and you should find that WindowBuilder 
Pro is now reenabled.      

Windows 95 Tab Control
----------------------

This control has a limitation in its handling of bitmap image 
labels. If you choose to use bitmaps for tab labels, the 
bitmaps must all be of a uniform size. If the bitmaps have 
different sizes, a runtime error will occur.

Windows 95 RichEdit Control
---------------------------

This widget is very buggy and prone to initialization problems. 
After placing this widget into WBPro, you may experience an OS 
error when you attempt to launch its attribute editor (the 
attribute editor itself employs a RichEdit widget). The 
workaround is to test launch the window with the RichEdit 
widget first. This seems to properly initialize the widget. 
From then on the attribute editor should come up normally. This 
workaround only needs to be used once per session.

WBPro & MDI Development Mode
----------------------------

Due to changes made to the VisualSmalltalk base, WindowBuilder 
Pro is incompatible with the MDI Development mode. If WBPro is 
installed, you will not be able to successfully switch to MDI 
Development mode. This does not affect your ability to develop 
MDI enabled applications in the normal manner. We hope to have 
this problem corrected in the first maintenance release.

NLS & Menu Items
----------------

Currently, WBPro is able to generate NLS keys only for menu 
items that *do not* have accelerator keys associated with them. 
This is due to a limitation in the base image protocols for 
creating menu items. We hope to have a viable workaround for 
this in time for the first maintenance release.

CompositePanes & PARTS
----------------------

Due to changes made to PARTS Workbench, dropping a WBPro-generated 
CompositePane into PARTS Workbench will cause a walkback. We hope
to have the problem corrected soon.


GENERAL NOTE ON TECH SUPPORT
============================

When contacting a vendor for tech support (whether it be us, 
Digitalk, or any other), it is crucial to do your homework:

1) If you think you have discovered a bug in a vendor's 
product, try to reproduce the bug in a *clean* image (totally 
clean if is a base image problem, or clean plus WBPro if you 
suspect a WBPro problem). Try to keep your example simple when 
doing this to remove as many other dependencies as possible. 
Most of the time people will discover their own errors and not 
need to call at all. In any case, doing so will help you 
clarify the problem in your own mind and help us help you all 
the quicker.

2) If you suspect a hardware problem (generally video driver 
related), try testing that by running your example under 
640x480 256 color VGA, or on a buddy's machine (with different 
hardware).

3) Once you have identified a real problem, try to identify the 
real "owner" of the problem. If it has to do with WBPro or one 
of our widgets, call us. If it is clearly identifiable as a 
base image widget problem, call Digitalk. If you honestly can't 
make that determination or you aren't sure, then call us - 
we'll be happy to help you figure out what is going on.

4) When you call us, have your complete walkback listing handy 
and be prepared to send us a small example to reproduce the 
problem (particularly if it can't be reproduced easily over the 
phone). Don't expect an immediate answer. If it is not 
immediately obvious, it might take us a little while to figure 
it out - hopefully not more than a day or two. 

And above all else, be nice and try to remain objective (it 
might very well not be a bug in our product that is causing 
your problem). The nicer you are about it, the more likely we 
are to go out of our way to help you - regardless of whether it 
is our problem or not.


OSI'S SUPPORT POLICY
====================

We provide 90 days of free support for WindowBuilder Pro to REGISTERED
users, Monday-Friday, from 8:30 AM to 2:30 PM, Pacific Standard 
Time. If you have purchased Subpanes/V but have not registered
it, we will not provide support. Additional support contracts 
may be purchased for a nominal fee and include automatic upgrades 
and bug fix disks - contact OSI for details. Because we are a 
small company with limited resources, we prefer to handle support 
questions via e-mail or fax (408) 970-7282. You can also call 
in to our order and support system at (408) 970-7280. When 
faxing in or calling in a support request please provide as 
much information as possible. The following details will be 
needed for us to provide prompt support:

1.  Version and serial number of your WindowBuilder Pro product
2.  Version number of the Digitalk Smalltalk you are using
3.  Version number of the operating system you are using
4.  Special information such as any Smalltalk version control 
    software that you are using (e.g., Team/V, ENVY, Xoteryx, etc.)
5.  Any special information about your configuration.

    Objectshare Systems, Inc.
    3160 De La Cruz Blvd.
    Suite 205
    Santa Clara, CA 95054-2408

    Order / Support:    (408) 970-7280
    Fax:                (408) 970-7282
    Compuserve:         74012,2123

** We anticipate some confusion over the ownership of problems 
** associated with WindowBuilder Pro.  Please keep in mind that 
** the widgets provided by VisualSmalltalk are products of 
** Digitalk, not Objectshare Systems, Inc. If your problem is 
** related to widget or base system functionality, please refer to 
** Digitalk for support. Our technical support is strictly limited 
** to problems in the runtime or development protions of 
** WindowBuilder Pro. Problems with runtime specific behavior of 
** base image widgets should be referred to Digitalk.
