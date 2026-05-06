pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property var groups: [
        {
                "id": "general",
                "label": "General",
                "icon": "sliders-horizontal-arrow-symbolic",
                "sections": [
                        {
                                "id": "general",
                                "label": "Gaps",
                                "options": [
                                        {
                                                "key": "general:gaps_in",
                                                "label": "Inner gaps",
                                                "type": "int",
                                                "defaultValue": 5,
                                                "description": "Gaps between windows in pixels",
                                                "min": 0,
                                                "max": 100,
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "general:gaps_out",
                                                "label": "Outer gaps",
                                                "type": "int",
                                                "defaultValue": 20,
                                                "description": "Gaps between windows and monitor edges in pixels",
                                                "min": 0,
                                                "max": 100,
                                                "step": 1,
                                                "suffix": "px"
                                        }
                                ]
                        },
                        {
                                "id": "general:borders",
                                "label": "Borders",
                                "options": [
                                        {
                                                "key": "general:border_size",
                                                "label": "Border size",
                                                "type": "int",
                                                "defaultValue": 1,
                                                "description": "Size of the border around windows",
                                                "min": 0,
                                                "max": 20,
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "general:resize_on_border",
                                                "label": "Resize on border",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enables resizing windows by clicking and dragging on borders and gaps"
                                        },
                                        {
                                                "key": "general:extend_border_grab_area",
                                                "label": "Extend border grab area",
                                                "type": "int",
                                                "defaultValue": 15,
                                                "description": "Extends the area around the border where you can click and drag for resize",
                                                "min": 0,
                                                "max": 100,
                                                "dependsOn": "general:resize_on_border",
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "general:hover_icon_on_border",
                                                "label": "Hover icon on border",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Show a cursor icon when hovering on borders",
                                                "dependsOn": "general:resize_on_border"
                                        }
                                ]
                        },
                        {
                                "id": "general:border_colors",
                                "label": "Border Colors",
                                "options": [
                                        {
                                                "key": "general:col.active_border",
                                                "label": "Active border color",
                                                "type": "gradient",
                                                "defaultValue": "0xffffffff",
                                                "description": "Border color for the active window"
                                        },
                                        {
                                                "key": "general:col.inactive_border",
                                                "label": "Inactive border color",
                                                "type": "gradient",
                                                "defaultValue": "0xff444444",
                                                "description": "Border color for inactive windows"
                                        }
                                ]
                        },
                        {
                                "id": "general:layout",
                                "label": "Layout",
                                "options": [
                                        {
                                                "key": "general:layout",
                                                "label": "Layout",
                                                "type": "choice",
                                                "defaultValue": "dwindle",
                                                "description": "Which layout to use for tiling",
                                                "values": [
                                                        {
                                                                "id": "dwindle",
                                                                "label": "Dwindle"
                                                        },
                                                        {
                                                                "id": "master",
                                                                "label": "Master"
                                                        },
                                                        {
                                                                "id": "scrolling",
                                                                "label": "Scrolling"
                                                        },
                                                        {
                                                                "id": "monocle",
                                                                "label": "Monocle"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "general:allow_tearing",
                                                "label": "Allow tearing",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Allow screen tearing for reduced latency"
                                        }
                                ]
                        },
                        {
                                "id": "general:snap",
                                "label": "Snap",
                                "options": [
                                        {
                                                "key": "general:snap:enabled",
                                                "label": "Enable snap",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enable snapping for floating windows"
                                        },
                                        {
                                                "key": "general:snap:window_gap",
                                                "label": "Window snap gap",
                                                "type": "int",
                                                "defaultValue": 10,
                                                "description": "Minimum gap in pixels between windows before snapping",
                                                "min": 0,
                                                "max": 100,
                                                "dependsOn": "general:snap:enabled",
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "general:snap:monitor_gap",
                                                "label": "Monitor snap gap",
                                                "type": "int",
                                                "defaultValue": 10,
                                                "description": "Minimum gap in pixels between window and monitor edges before snapping",
                                                "min": 0,
                                                "max": 100,
                                                "dependsOn": "general:snap:enabled",
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "general:snap:border_overlap",
                                                "label": "Border overlap",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "If true, windows snap such that only one border's worth of space is between them",
                                                "dependsOn": "general:snap:enabled"
                                        },
                                        {
                                                "key": "general:snap:respect_gaps",
                                                "label": "Respect gaps",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "If true, snapping will respect gaps between windows",
                                                "dependsOn": "general:snap:enabled"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "decoration",
                "label": "Decoration",
                "icon": "appearance-symbolic",
                "sections": [
                        {
                                "id": "decoration",
                                "label": "Rounding and Opacity",
                                "options": [
                                        {
                                                "key": "decoration:rounding",
                                                "label": "Corner rounding",
                                                "type": "int",
                                                "defaultValue": 0,
                                                "description": "Rounded corners' radius (in layout px)",
                                                "min": 0,
                                                "max": 50,
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "decoration:rounding_power",
                                                "label": "Rounding power",
                                                "type": "float",
                                                "defaultValue": 2.0,
                                                "description": "Rounding power of corners (2 is a circle)",
                                                "min": 2.0,
                                                "max": 10.0,
                                                "step": 0.1
                                        },
                                        {
                                                "key": "decoration:active_opacity",
                                                "label": "Active opacity",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Opacity of active windows",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "decoration:inactive_opacity",
                                                "label": "Inactive opacity",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Opacity of inactive windows",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "decoration:fullscreen_opacity",
                                                "label": "Fullscreen opacity",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Opacity of fullscreen windows",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "decoration:dim_inactive",
                                                "label": "Dim inactive",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enables dimming of inactive windows"
                                        },
                                        {
                                                "key": "decoration:dim_strength",
                                                "label": "Dim strength",
                                                "type": "float",
                                                "defaultValue": 0.5,
                                                "description": "How much to dim inactive windows",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05,
                                                "dependsOn": "decoration:dim_inactive"
                                        },
                                        {
                                                "key": "decoration:dim_around",
                                                "label": "Dim around",
                                                "type": "float",
                                                "defaultValue": 0.4,
                                                "description": "Dim factor for floating windows when a dialog is open",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "decoration:dim_special",
                                                "label": "Dim special",
                                                "type": "float",
                                                "defaultValue": 0.2,
                                                "description": "Dim the rest of the screen when a special workspace is open",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        }
                                ]
                        },
                        {
                                "id": "decoration:blur",
                                "label": "Blur",
                                "options": [
                                        {
                                                "key": "decoration:blur:enabled",
                                                "label": "Enable blur",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Enable kawase window background blur"
                                        },
                                        {
                                                "key": "decoration:blur:size",
                                                "label": "Blur size",
                                                "type": "int",
                                                "defaultValue": 8,
                                                "description": "Blur radius in pixels",
                                                "min": 1,
                                                "max": 100,
                                                "dependsOn": "decoration:blur:enabled",
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "decoration:blur:passes",
                                                "label": "Blur passes",
                                                "type": "int",
                                                "defaultValue": 1,
                                                "description": "The amount of passes to perform",
                                                "min": 1,
                                                "max": 10,
                                                "dependsOn": "decoration:blur:enabled",
                                                "step": 1
                                        },
                                        {
                                                "key": "decoration:blur:ignore_opacity",
                                                "label": "Ignore opacity",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Make the blur layer ignore the opacity of the window",
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:new_optimizations",
                                                "label": "New optimizations",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Enable further optimizations to the blur (recommended)",
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:xray",
                                                "label": "X-Ray",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "If enabled, floating windows will ignore tiled windows in their blur",
                                                "dependsOn": "decoration:blur:new_optimizations"
                                        },
                                        {
                                                "key": "decoration:blur:noise",
                                                "label": "Blur noise",
                                                "type": "float",
                                                "defaultValue": 0.0117,
                                                "description": "How much noise to apply to the blur",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.001,
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:contrast",
                                                "label": "Blur contrast",
                                                "type": "float",
                                                "defaultValue": 0.8916,
                                                "description": "Contrast modulation for blur",
                                                "min": 0.0,
                                                "max": 2.0,
                                                "step": 0.01,
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:brightness",
                                                "label": "Blur brightness",
                                                "type": "float",
                                                "defaultValue": 0.8172,
                                                "description": "Brightness modulation for blur",
                                                "min": 0.0,
                                                "max": 2.0,
                                                "step": 0.01,
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:vibrancy",
                                                "label": "Blur vibrancy",
                                                "type": "float",
                                                "defaultValue": 0.1696,
                                                "description": "Increase saturation of blurred colors",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.01,
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:vibrancy_darkness",
                                                "label": "Blur vibrancy darkness",
                                                "type": "float",
                                                "defaultValue": 0.0,
                                                "description": "How much to increase saturation of dark colors",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.01,
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:special",
                                                "label": "Blur special workspaces",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Whether to blur behind the special workspace (note: expensive)",
                                                "dependsOn": "decoration:blur:enabled"
                                        },
                                        {
                                                "key": "decoration:blur:popups",
                                                "label": "Blur popups",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Whether to blur popups (e.g. right-click menus)",
                                                "dependsOn": "decoration:blur:enabled"
                                        }
                                ]
                        },
                        {
                                "id": "decoration:shadow",
                                "label": "Shadow",
                                "options": [
                                        {
                                                "key": "decoration:shadow:enabled",
                                                "label": "Enable shadow",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Enable drop shadows on windows"
                                        },
                                        {
                                                "key": "decoration:shadow:range",
                                                "label": "Shadow range",
                                                "type": "int",
                                                "defaultValue": 4,
                                                "description": "Shadow range (size) in layout px",
                                                "min": 0,
                                                "max": 100,
                                                "dependsOn": "decoration:shadow:enabled",
                                                "step": 1,
                                                "suffix": "px"
                                        },
                                        {
                                                "key": "decoration:shadow:render_power",
                                                "label": "Shadow render power",
                                                "type": "int",
                                                "defaultValue": 3,
                                                "description": "Higher values produce a faster shadow falloff",
                                                "min": 1,
                                                "max": 4,
                                                "dependsOn": "decoration:shadow:enabled",
                                                "step": 1
                                        },
                                        {
                                                "key": "decoration:shadow:ignore_window",
                                                "label": "Ignore window",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "If true, the shadow will not be rendered behind the window itself, only around it.",
                                                "dependsOn": "decoration:shadow:enabled"
                                        },
                                        {
                                                "key": "decoration:shadow:offset",
                                                "label": "Shadow offset",
                                                "type": "vec2",
                                                "defaultValue": "0 0",
                                                "description": "Shadow position offset as 'x y' in pixels",
                                                "dependsOn": "decoration:shadow:enabled"
                                        },
                                        {
                                                "key": "decoration:shadow:scale",
                                                "label": "Shadow scale",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Scale factor for the shadow relative to the window",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05,
                                                "dependsOn": "decoration:shadow:enabled"
                                        },
                                        {
                                                "key": "decoration:shadow:color",
                                                "label": "Shadow color",
                                                "type": "color",
                                                "defaultValue": "0xee1a1a1a",
                                                "description": "Shadow's color. Alpha dictates shadow's opacity.",
                                                "dependsOn": "decoration:shadow:enabled"
                                        },
                                        {
                                                "key": "decoration:shadow:color_inactive",
                                                "label": "Inactive shadow color",
                                                "type": "color",
                                                "defaultValue": "0xee1a1a1a",
                                                "description": "Inactive shadow color. (if not set, will fall back to col.shadow)",
                                                "dependsOn": "decoration:shadow:enabled"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "animations",
                "label": "Animations",
                "icon": "bounce-symbolic",
                "sections": [
                        {
                                "id": "animations",
                                "label": "General",
                                "options": [
                                        {
                                                "key": "animations:enabled",
                                                "label": "Enable animations",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Master switch for all window and workspace animations"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "input",
                "label": "Devices",
                "icon": "input-keyboard-symbolic",
                "sections": [
                        {
                                "id": "input",
                                "label": "Keyboard",
                                "options": [
                                        {
                                                "key": "input:kb_layout",
                                                "label": "Keyboard layout",
                                                "type": "string",
                                                "defaultValue": "us",
                                                "description": "Keyboard layout code (e.g. us, de, fr)",
                                                "source": "xkb_layouts"
                                        },
                                        {
                                                "key": "input:kb_variant",
                                                "label": "Keyboard variant",
                                                "type": "string",
                                                "defaultValue": "",
                                                "description": "Variant of the selected keyboard layout (e.g. dvorak, colemak)",
                                                "dependsOn": "input:kb_layout",
                                                "source": "xkb_variants",
                                                "sourceArgs": {
                                                        "layout": "us"
                                                }
                                        },
                                        {
                                                "key": "input:kb_options",
                                                "label": "Keyboard options",
                                                "type": "string",
                                                "defaultValue": "",
                                                "description": "Modifier keys, layout switching, and other keyboard tweaks",
                                                "multi": true,
                                                "source": "xkb_options"
                                        },
                                        {
                                                "key": "input:numlock_by_default",
                                                "label": "Numlock by default",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enable numlock on startup"
                                        },
                                        {
                                                "key": "input:repeat_rate",
                                                "label": "Repeat rate",
                                                "type": "int",
                                                "defaultValue": 25,
                                                "description": "The repeat rate for held-down keys, in repeats per second.",
                                                "min": 0,
                                                "max": 200,
                                                "step": 1
                                        },
                                        {
                                                "key": "input:repeat_delay",
                                                "label": "Repeat delay",
                                                "type": "int",
                                                "defaultValue": 600,
                                                "description": "Delay before a held-down key is repeated, in milliseconds.",
                                                "min": 0,
                                                "max": 2000,
                                                "step": 1,
                                                "suffix": "px"
                                        }
                                ]
                        },
                        {
                                "id": "input:mouse",
                                "label": "Mouse",
                                "options": [
                                        {
                                                "key": "input:sensitivity",
                                                "label": "Mouse sensitivity",
                                                "type": "float",
                                                "defaultValue": 0.0,
                                                "description": "Mouse sensitivity (-1.0 to 1.0, 0 is default)",
                                                "min": -1.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "input:accel_profile",
                                                "label": "Acceleration profile",
                                                "type": "choice",
                                                "defaultValue": "",
                                                "description": "How cursor speed changes relative to mouse movement speed",
                                                "values": [
                                                        {
                                                                "id": "",
                                                                "label": "Default"
                                                        },
                                                        {
                                                                "id": "flat",
                                                                "label": "Flat"
                                                        },
                                                        {
                                                                "id": "adaptive",
                                                                "label": "Adaptive"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "input:follow_mouse",
                                                "label": "Follow mouse",
                                                "type": "choice",
                                                "defaultValue": 1,
                                                "description": "Window focus follows mouse movement",
                                                "values": [
                                                        {
                                                                "label": "Disabled"
                                                        },
                                                        {
                                                                "label": "Full"
                                                        },
                                                        {
                                                                "label": "Loose"
                                                        },
                                                        {
                                                                "label": "Loose (no mouse focus)"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "input:natural_scroll",
                                                "label": "Natural scroll",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enable natural (inverted) scrolling"
                                        },
                                        {
                                                "key": "input:scroll_factor",
                                                "label": "Scroll factor",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Multiplier for scroll amount",
                                                "min": 0.1,
                                                "max": 10.0,
                                                "step": 0.1
                                        },
                                        {
                                                "key": "input:left_handed",
                                                "label": "Left-handed mode",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Switches RMB and LMB"
                                        },
                                        {
                                                "key": "input:mouse_refocus",
                                                "label": "Mouse refocus",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Re-focus the window under the cursor when switching workspaces"
                                        },
                                        {
                                                "key": "input:float_switch_override_focus",
                                                "label": "Float switch override focus",
                                                "type": "choice",
                                                "defaultValue": 1,
                                                "description": "Focus the window under cursor when switching between tiled and floating",
                                                "values": [
                                                        {
                                                                "label": "Disabled"
                                                        },
                                                        {
                                                                "label": "Enabled"
                                                        },
                                                        {
                                                                "label": "Enabled (also unfocuses)"
                                                        }
                                                ]
                                        }
                                ]
                        },
                        {
                                "id": "input:touchpad",
                                "label": "Touchpad",
                                "options": [
                                        {
                                                "key": "input:touchpad:disable_while_typing",
                                                "label": "Disable while typing",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Ignore touchpad input while typing on the keyboard"
                                        },
                                        {
                                                "key": "input:touchpad:natural_scroll",
                                                "label": "Natural scroll",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enable natural scrolling on touchpad"
                                        },
                                        {
                                                "key": "input:touchpad:tap-to-click",
                                                "label": "Tap to click",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Tapping sends a click (1, 2, or 3 fingers for LMB, RMB, MMB)"
                                        },
                                        {
                                                "key": "input:touchpad:clickfinger_behavior",
                                                "label": "Clickfinger behavior",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Use finger count instead of button areas for click mapping"
                                        },
                                        {
                                                "key": "input:touchpad:tap_button_map",
                                                "label": "Tap button map",
                                                "type": "choice",
                                                "defaultValue": "",
                                                "description": "Sets the tap button mapping for touchpad button emulation. Can be one of lrm (default) or lmr (Left, Middle, Right Buttons). [lrm/lmr]",
                                                "values": [
                                                        {
                                                                "id": "",
                                                                "label": "Default"
                                                        },
                                                        {
                                                                "id": "lrm",
                                                                "label": "Left, Right, Middle"
                                                        },
                                                        {
                                                                "id": "lmr",
                                                                "label": "Left, Middle, Right"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "input:touchpad:middle_button_emulation",
                                                "label": "Middle button emulation",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Press left and right buttons simultaneously to emulate middle click"
                                        },
                                        {
                                                "key": "input:touchpad:drag_lock",
                                                "label": "Drag lock",
                                                "type": "choice",
                                                "defaultValue": 0,
                                                "description": "Drag lock mode for tap-and-drag",
                                                "values": [
                                                        {
                                                                "label": "Disabled"
                                                        },
                                                        {
                                                                "label": "Enabled with timeout"
                                                        },
                                                        {
                                                                "label": "Sticky"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "input:touchpad:scroll_factor",
                                                "label": "Touchpad scroll factor",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Multiplier applied to the amount of scroll movement.",
                                                "min": 0.1,
                                                "max": 10.0,
                                                "step": 0.1
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "cursor",
                "label": "Cursor",
                "icon": "hyprmod-cursor-symbolic",
                "sections": [
                        {
                                "id": "cursor",
                                "label": "General",
                                "options": [
                                        {
                                                "key": "cursor:no_hardware_cursors",
                                                "label": "Hardware cursors",
                                                "type": "choice",
                                                "defaultValue": 0,
                                                "description": "Disables hardware cursors. Auto = disable when multi-gpu on nvidia",
                                                "values": [
                                                        {
                                                                "id": "0",
                                                                "label": "Disabled"
                                                        },
                                                        {
                                                                "id": "1",
                                                                "label": "Enabled"
                                                        },
                                                        {
                                                                "id": "2",
                                                                "label": "Auto"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "cursor:enable_hyprcursor",
                                                "label": "Enable Hyprcursor",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Whether to enable hyprcursor support"
                                        },
                                        {
                                                "key": "cursor:no_warps",
                                                "label": "Disable cursor warps",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Do not warp the cursor when focusing, using keybinds, etc."
                                        },
                                        {
                                                "key": "cursor:persistent_warps",
                                                "label": "Persistent warps",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Remember cursor position per window when warping back"
                                        },
                                        {
                                                "key": "cursor:warp_on_change_workspace",
                                                "label": "Warp on workspace change",
                                                "type": "choice",
                                                "defaultValue": 0,
                                                "description": "Move cursor to the last focused window after switching workspaces. Force ignores the no_warps setting.",
                                                "values": [
                                                        {
                                                                "id": "0",
                                                                "label": "Disabled"
                                                        },
                                                        {
                                                                "id": "1",
                                                                "label": "Enabled"
                                                        },
                                                        {
                                                                "id": "2",
                                                                "label": "Force"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "cursor:zoom_factor",
                                                "label": "Zoom factor",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "The factor to zoom by around the cursor. Like a magnifying glass. Minimum 1.0 (meaning no zoom)",
                                                "min": 1.0,
                                                "max": 10.0,
                                                "step": 0.1
                                        }
                                ]
                        },
                        {
                                "id": "cursor:visibility",
                                "label": "Visibility",
                                "options": [
                                        {
                                                "key": "cursor:inactive_timeout",
                                                "label": "Inactive timeout",
                                                "type": "int",
                                                "defaultValue": 0,
                                                "description": "Seconds before hiding cursor (0 to never hide)",
                                                "min": 0,
                                                "max": 20,
                                                "step": 1
                                        },
                                        {
                                                "key": "cursor:hide_on_key_press",
                                                "label": "Hide on key press",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Hides the cursor when you press any key until the mouse is moved."
                                        },
                                        {
                                                "key": "cursor:hide_on_touch",
                                                "label": "Hide on touch",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Hides the cursor when the last input was a touch input until a mouse input is done."
                                        },
                                        {
                                                "key": "cursor:hide_on_tablet",
                                                "label": "Hide on tablet",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Hides the cursor when the last input was a tablet input until a mouse input is done."
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "gestures",
                "label": "Gestures",
                "icon": "gesture-swipe-left-symbolic",
                "sections": [
                        {
                                "id": "gestures",
                                "label": "Workspace Swipe",
                                "options": [
                                        {
                                                "key": "gestures:workspace_swipe_create_new",
                                                "label": "Create new workspace",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Swiping past the last workspace creates a new one"
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_forever",
                                                "label": "Swipe forever",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Keep swiping through workspaces without limits"
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_cancel_ratio",
                                                "label": "Cancel ratio",
                                                "type": "float",
                                                "defaultValue": 0.5,
                                                "description": "How far you need to swipe before the gesture commits",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_min_speed_to_force",
                                                "label": "Min speed to force",
                                                "type": "int",
                                                "defaultValue": 30,
                                                "description": "Minimum swipe speed to force the gesture regardless of distance",
                                                "min": 0,
                                                "max": 200,
                                                "step": 1
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_direction_lock",
                                                "label": "Direction lock",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Lock gesture to a single direction once started"
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_use_r",
                                                "label": "Use relative workspaces",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Swipe through relative workspaces instead of absolute"
                                        }
                                ]
                        },
                        {
                                "id": "gestures:touchpad",
                                "label": "Touchpad",
                                "options": [
                                        {
                                                "key": "gestures:workspace_swipe_distance",
                                                "label": "Swipe distance",
                                                "type": "int",
                                                "defaultValue": 300,
                                                "description": "Distance in pixels for the touchpad swipe gesture",
                                                "min": 0,
                                                "max": 2000,
                                                "step": 1
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_invert",
                                                "label": "Invert direction",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Invert the direction (touchpad only)"
                                        }
                                ]
                        },
                        {
                                "id": "gestures:touchscreen",
                                "label": "Touchscreen",
                                "options": [
                                        {
                                                "key": "gestures:workspace_swipe_touch",
                                                "label": "Touch swipe",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enable workspace swipe via touchscreen"
                                        },
                                        {
                                                "key": "gestures:workspace_swipe_touch_invert",
                                                "label": "Invert touch direction",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Invert the direction (touchscreen only)",
                                                "dependsOn": "gestures:workspace_swipe_touch"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "dwindle",
                "label": "Dwindle",
                "icon": "grid-filled-symbolic",
                "sections": [
                        {
                                "id": "dwindle",
                                "label": "Split Behavior",
                                "options": [
                                        {
                                                "key": "dwindle:preserve_split",
                                                "label": "Preserve split",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Split direction won't change when the container is resized"
                                        },
                                        {
                                                "key": "dwindle:pseudotile",
                                                "label": "Pseudotile",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Pseudotiled windows retain their floating size when tiled"
                                        },
                                        {
                                                "key": "dwindle:force_split",
                                                "label": "Force split direction",
                                                "type": "choice",
                                                "defaultValue": 0,
                                                "description": "0 -> split follows mouse, 1 -> always split to the left (new = left or top) 2 -> always split to the right (new = right or bottom)",
                                                "values": [
                                                        {
                                                                "label": "Follow mouse"
                                                        },
                                                        {
                                                                "label": "Left / Top"
                                                        },
                                                        {
                                                                "label": "Right / Bottom"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "dwindle:smart_split",
                                                "label": "Smart split",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Split direction is based on cursor position within the window"
                                        },
                                        {
                                                "key": "dwindle:default_split_ratio",
                                                "label": "Default split ratio",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "The default split ratio on window open. 1 means even 50/50 split. [0.1 - 1.9]",
                                                "min": 0.1,
                                                "max": 1.9,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "dwindle:split_width_multiplier",
                                                "label": "Split width multiplier",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Specifies the auto-split width multiplier",
                                                "min": 0.1,
                                                "max": 3.0,
                                                "step": 0.1
                                        },
                                        {
                                                "key": "dwindle:permanent_direction_override",
                                                "label": "Permanent direction override",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "If enabled, makes the preselect direction persist until either this mode is turned off, another direction is specified, or a non-direction is specified (anything other than l,r,u/t,d/b)"
                                        },
                                        {
                                                "key": "dwindle:use_active_for_splits",
                                                "label": "Use active for splits",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Whether to prefer the active window or the mouse position for splits"
                                        }
                                ]
                        },
                        {
                                "id": "dwindle:other",
                                "label": "Other",
                                "options": [
                                        {
                                                "key": "dwindle:smart_resizing",
                                                "label": "Smart resizing",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "If enabled, resizing direction will be determined by the mouse's position on the window (nearest to which corner). Else, it is based on the window's tiling position."
                                        },
                                        {
                                                "key": "dwindle:special_scale_factor",
                                                "label": "Special workspace scale",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "Specifies the scale factor of windows on the special workspace [0 - 1]",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "master",
                "label": "Master",
                "icon": "menu-large-symbolic",
                "sections": [
                        {
                                "id": "master",
                                "label": "Layout",
                                "options": [
                                        {
                                                "key": "master:orientation",
                                                "label": "Orientation",
                                                "type": "choice",
                                                "defaultValue": "left",
                                                "description": "Default placement of the master area, can be left, right, top, bottom or center",
                                                "values": [
                                                        {
                                                                "id": "left",
                                                                "label": "Left"
                                                        },
                                                        {
                                                                "id": "right",
                                                                "label": "Right"
                                                        },
                                                        {
                                                                "id": "top",
                                                                "label": "Top"
                                                        },
                                                        {
                                                                "id": "bottom",
                                                                "label": "Bottom"
                                                        },
                                                        {
                                                                "id": "center",
                                                                "label": "Center"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "master:mfact",
                                                "label": "Master factor",
                                                "type": "float",
                                                "defaultValue": 0.55,
                                                "description": "Size of the master area as a percentage of the screen",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "master:new_status",
                                                "label": "New window status",
                                                "type": "choice",
                                                "defaultValue": "slave",
                                                "description": "`master`: new window becomes master; `slave`: new windows are added to slave stack; `inherit`: inherit from focused window",
                                                "values": [
                                                        {
                                                                "id": "master",
                                                                "label": "Master"
                                                        },
                                                        {
                                                                "id": "slave",
                                                                "label": "Slave"
                                                        },
                                                        {
                                                                "id": "inherit",
                                                                "label": "Inherit"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "master:new_on_top",
                                                "label": "New on top",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Whether a newly open window should be on the top of the stack"
                                        },
                                        {
                                                "key": "master:new_on_active",
                                                "label": "New window placement",
                                                "type": "choice",
                                                "defaultValue": "none",
                                                "description": "`before`, `after`: place new window relative to the focused window; `none`: place new window according to the value of `new_on_top`.",
                                                "values": [
                                                        {
                                                                "id": "none",
                                                                "label": "None"
                                                        },
                                                        {
                                                                "id": "before",
                                                                "label": "Before active"
                                                        },
                                                        {
                                                                "id": "after",
                                                                "label": "After active"
                                                        }
                                                ]
                                        }
                                ]
                        },
                        {
                                "id": "master:other",
                                "label": "Other",
                                "options": [
                                        {
                                                "key": "master:smart_resizing",
                                                "label": "Smart resizing",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "If enabled, resizing direction will be determined by the mouse's position on the window (nearest to which corner). Else, it is based on the window's tiling position."
                                        },
                                        {
                                                "key": "master:special_scale_factor",
                                                "label": "Special workspace scale",
                                                "type": "float",
                                                "defaultValue": 1.0,
                                                "description": "The scale of the special workspace windows. [0.0 - 1.0]",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "master:allow_small_split",
                                                "label": "Allow small split",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Enable adding additional master windows in a horizontal split style"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "scrolling",
                "label": "Scrolling",
                "icon": "view-more-symbolic",
                "sections": [
                        {
                                "id": "scrolling",
                                "label": "Columns",
                                "options": [
                                        {
                                                "key": "scrolling:column_width",
                                                "label": "Default column width",
                                                "type": "float",
                                                "defaultValue": 0.5,
                                                "description": "Default width of a column as a fraction of the screen",
                                                "min": 0.1,
                                                "max": 1.0,
                                                "step": 0.05
                                        },
                                        {
                                                "key": "scrolling:explicit_column_widths",
                                                "label": "Preset column widths",
                                                "type": "string",
                                                "defaultValue": "0.333, 0.5, 0.667, 1.0",
                                                "description": "A comma-separated list of preconfigured widths for colresize +conf/-conf"
                                        },
                                        {
                                                "key": "scrolling:direction",
                                                "label": "Scroll direction",
                                                "type": "choice",
                                                "defaultValue": "right",
                                                "description": "Direction in which new windows appear and the layout scrolls",
                                                "values": [
                                                        {
                                                                "id": "right",
                                                                "label": "Right"
                                                        },
                                                        {
                                                                "id": "left",
                                                                "label": "Left"
                                                        },
                                                        {
                                                                "id": "down",
                                                                "label": "Down"
                                                        },
                                                        {
                                                                "id": "up",
                                                                "label": "Up"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "scrolling:fullscreen_on_one_column",
                                                "label": "Single column fullscreen",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "When enabled, a single column on a workspace will always span the entire screen."
                                        }
                                ]
                        },
                        {
                                "id": "scrolling:focus",
                                "label": "Focus",
                                "options": [
                                        {
                                                "key": "scrolling:focus_fit_method",
                                                "label": "Focus fit method",
                                                "type": "choice",
                                                "defaultValue": 0,
                                                "description": "When a column is focused, what method should be used to bring it into view",
                                                "values": [
                                                        {
                                                                "label": "Center"
                                                        },
                                                        {
                                                                "label": "Fit"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "scrolling:follow_focus",
                                                "label": "Follow focus",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Move the layout automatically to bring the focused window into view"
                                        },
                                        {
                                                "key": "scrolling:follow_min_visible",
                                                "label": "Minimum visible fraction",
                                                "type": "float",
                                                "defaultValue": 0.4,
                                                "description": "When a window is focused, require that at least a given fraction of it is visible for focus to follow",
                                                "min": 0.0,
                                                "max": 1.0,
                                                "step": 0.05,
                                                "dependsOn": "scrolling:follow_focus"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "xwayland",
                "label": "XWayland",
                "icon": "application-x-executable-symbolic",
                "sections": [
                        {
                                "id": "xwayland",
                                "label": "XWayland",
                                "options": [
                                        {
                                                "key": "xwayland:enabled",
                                                "label": "Enable XWayland",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Allow running applications using X11"
                                        },
                                        {
                                                "key": "xwayland:force_zero_scaling",
                                                "label": "Force zero scaling",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Force apps to use Wayland-native scaling instead of X11 scaling"
                                        },
                                        {
                                                "key": "xwayland:use_nearest_neighbor",
                                                "label": "Use nearest neighbor",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Use nearest-neighbor filtering for upscaling XWayland apps"
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "ecosystem",
                "label": "Ecosystem",
                "icon": "sprout-symbolic",
                "sections": [
                        {
                                "id": "ecosystem",
                                "label": "Ecosystem",
                                "options": [
                                        {
                                                "key": "ecosystem:no_update_news",
                                                "label": "Disable update news",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Disable the popup when Hyprland is updated to a new version"
                                        },
                                        {
                                                "key": "ecosystem:no_donation_nag",
                                                "label": "Disable donation nag",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Disable the donation popup that shows twice a year"
                                        },
                                        {
                                                "key": "ecosystem:enforce_permissions",
                                                "label": "Enforce permissions",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Whether to enable permission control (see https://wiki.hypr.land/Configuring/Permissions/)."
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "monitor_globals",
                "label": "Display Settings",
                "icon": "",
                "sections": [
                        {
                                "id": "monitor_globals",
                                "label": "Display Settings",
                                "options": [
                                        {
                                                "key": "misc:vrr",
                                                "label": "Variable refresh rate",
                                                "type": "choice",
                                                "defaultValue": 0,
                                                "description": "Controls adaptive sync globally",
                                                "values": [
                                                        {
                                                                "label": "Off"
                                                        },
                                                        {
                                                                "label": "On"
                                                        },
                                                        {
                                                                "label": "Fullscreen only"
                                                        },
                                                        {
                                                                "label": "Fullscreen (game content)"
                                                        }
                                                ]
                                        },
                                        {
                                                "key": "misc:vfr",
                                                "label": "Variable frame rate",
                                                "type": "bool",
                                                "defaultValue": true,
                                                "description": "Enable variable frame rate (saves battery)"
                                        },
                                        {
                                                "key": "misc:mouse_move_enables_dpms",
                                                "label": "Mouse move enables DPMS",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "If DPMS is set to off, wake up the monitors if the mouse move"
                                        },
                                        {
                                                "key": "misc:key_press_enables_dpms",
                                                "label": "Key press enables DPMS",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "If DPMS is set to off, wake up the monitors if a key is pressed."
                                        }
                                ]
                        }
                ]
        },
        {
                "id": "misc",
                "label": "Miscellaneous",
                "icon": "applications-system-symbolic",
                "sections": [
                        {
                                "id": "misc",
                                "label": "Behavior",
                                "options": [
                                        {
                                                "key": "misc:disable_autoreload",
                                                "label": "Disable autoreload",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Disable config autoreload (manual reload via hyprctl reload)"
                                        },
                                        {
                                                "key": "misc:focus_on_activate",
                                                "label": "Focus on activate",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Whether to focus an app that requests to be focused"
                                        },
                                        {
                                                "key": "misc:animate_manual_resizes",
                                                "label": "Animate manual resizes",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Animate windows when manually resizing or moving them"
                                        },
                                        {
                                                "key": "misc:animate_mouse_windowdragging",
                                                "label": "Animate mouse window dragging",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Animate windows being dragged by the mouse"
                                        }
                                ]
                        },
                        {
                                "id": "misc:startup",
                                "label": "Startup",
                                "options": [
                                        {
                                                "key": "misc:disable_hyprland_logo",
                                                "label": "Disable Hyprland logo",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Disables the random Hyprland logo / anime girl background. :("
                                        },
                                        {
                                                "key": "misc:disable_splash_rendering",
                                                "label": "Disable splash rendering",
                                                "type": "bool",
                                                "defaultValue": false,
                                                "description": "Hide the splash text shown on the desktop after startup"
                                        },
                                        {
                                                "key": "misc:force_default_wallpaper",
                                                "label": "Force default wallpaper",
                                                "type": "int",
                                                "defaultValue": -1,
                                                "description": "Force the default wallpaper (-1 random, 0-2 for specific)",
                                                "min": -1,
                                                "max": 2,
                                                "step": 1
                                        }
                                ]
                        }
                ]
        }
]
}
