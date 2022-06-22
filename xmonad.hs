  -------------
  -- ACTIONS --
  -------------

-- import XMonad.Actions.CopyWindow (copyToAll)
-- import XMonad.Actions.CycleWS
-- import XMonad.Actions.WithAll (sinkAll, killAll)

  ----------
  -- BASE --
  ----------

import XMonad
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

  -----------
  -- HOOKS --
  -----------

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WindowSwallowing

  -------------
  -- LAYOUTS --
  -------------

import XMonad.Layout.SimplestFloat
import XMonad.Layout.Tabbed

  ---------------------
  -- LAYOUT MODIFIER --
  ---------------------

import XMonad.Layout.IndependentScreens
import XMonad.Layout.NoBorders

  -----------
  -- PYWAL --
  -----------

import Colors

  -----------
  -- UTILS --
  -----------

import XMonad.Util.EZConfig 
import XMonad.Util.Run

  ---------------
  -- VARIABLES --
  ---------------

myBrowser       = "$BROWSER "
myEditor        = "$EDITOR" 
myTerminal      = "$TERMINAL"

myFocusFollowsMouse = False
myClickJustFocuses = False

myBorderWidth   = 1

myModMask       = mod4Mask

myWorkspaces    = withScreens 2 ["\f268","\f120","3","4","5"]

myNormalBorderColor  = color5
myFocusedBorderColor = color6

  -----------------
  -- KEYBINDINGS --
  -----------------

additionalKeys =
        [ ("M-q", spawn "xmonad --restart")     
        , ("M-S-q", io exitSuccess)               

        , ("M-s", spawn "rofi -show combi") -- Dmenu

        , ("M-t", spawn (myTerminal))
        , ("M-b", spawn (myBrowser))
        , ("C-S-<Escape>", spawn (myTerminal ++ " start -- btop"))

        , ("M-S-c", kill)     -- Kill the currently focused client

        , ("M-.", nextScreen)  -- Switch focus to next monitor
        , ("M-,", prevScreen)  -- Switch focus to prev monitor
        , ("M-S-.", shiftNextScreen >> nextScreen)  -- Switch focus to next monitor
        , ("M-S-,", shiftPrevScreen >> prevScreen)  -- Switch focus to prev monitor

        , ("M-S-h", withFocused $ windows . W.sink)  -- Push floating window back to tile
        , ("M-S-l", sinkAll)                       -- Push ALL floating windows to tile

    -- KB_GROUP Grid Select (CTR-g followed by a key)
        -- , ("C-g g", spawnSelected' myAppGrid)                 -- grid select favorite apps
        -- , ("C-g t", goToSelected $ mygridConfig myColorizer)  -- goto selected window
        -- , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- KB_GROUP Windows navigation
        , ("M-m", windows W.focusMaster)  -- Move focus to the master window
        , ("M-k", windows W.focusDown)    -- Move focus to the next window
        , ("M-j", windows W.focusUp)      -- Move focus to the prev window
        , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
        , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
        -- , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
        -- , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
        -- , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

    -- KB_GROUP Layouts
        , ("M-<Tab>", sendMessage ToggleStruts)           -- Switch to next layout
        -- , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
        , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase # of clients master pane
        , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease # of clients master pane
        -- , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
        -- , ("M-C-<Down>", decreaseLimit)                 -- Decrease # of windows

    -- KB_GROUP Window resizing
        , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                   -- Expand horiz window width
        -- , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
        ]

myKeys conf = let modm = modMask conf in fromList $
    [((m .|. modm, k), windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]




--------------------------------------------------------------------------
---- Mouse bindings: default actions bound to mouse events
----

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-------------
-- LAYOUTS --
-------------

myLayout = avoidStruts (tiled ||| noBorders Full ||| simplestFloat)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------
-- WINDOW RULES --
------------------

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "osu!"           --> doFullFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore 
    , title =? "Picture in Picture" --> doFloat
    , title =? "Picture in Picture" --> doF copyToAll 
    , manageHook def
    , isFullscreen --> doFullFloat
    , manageDocks
    ]
------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = do
  swallowEventHook (className =? "org.wezfurlong.wezterm") (return True)

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  setWMName "LG3D"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmproc0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc"
  xmproc1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc"
  xmonad $ docks $ ewmh defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keyBindings        = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    } `additionalKeysP` additionalKeys
