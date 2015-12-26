﻿using System;
using OpenTK.Input;

namespace OpenBve
{
    internal static partial class MainLoop
    {
        /// <summary>Called when a KeyDown event is generated</summary>
        internal static void keyDownEvent(object sender, KeyboardKeyEventArgs e)
        {
            BlockKeyRepeat = true;
            //Check for modifiers
            if (e.Shift) CurrentKeyboardModifier |= Interface.KeyboardModifier.Shift;
            if (e.Control) CurrentKeyboardModifier |= Interface.KeyboardModifier.Ctrl;
            if (e.Alt) CurrentKeyboardModifier |= Interface.KeyboardModifier.Alt;
            if (Game.CurrentInterface == Game.InterfaceType.CustomiseControl)
            {
                //We now need to change the control reference & return.....
                Game.MenuEntry[] a = Game.CurrentMenu;
                int j = Game.CurrentMenuSelection.Length - 1;
                {
                    int k = 0;
                    while (k < j)
                    {
                        Game.MenuSubmenu b = a[Game.CurrentMenuSelection[k]] as Game.MenuSubmenu;
                        if (b == null) break;
                        a = b.Entries;
                        k++;
                    }
                }
                if (a[Game.CurrentMenuSelection[j]] is Game.MenuCommand)
                {
                    // command
                    Game.MenuCommand b = (Game.MenuCommand) a[Game.CurrentMenuSelection[j]];
                    if (b.Tag == Game.MenuTag.Control)
                    {
                        //Set control
                        Interface.CurrentControls[b.Data].Method = Interface.ControlMethod.Keyboard;
                        Interface.CurrentControls[b.Data].Key = e.Key;
                        Interface.CurrentControls[b.Data].Modifier = CurrentKeyboardModifier;
                    }
                    Game.CurrentInterface = Game.InterfaceType.Menu;
                    Interface.SaveControls(null);
                }
                return;
            }
            //Traverse the controls array
            for (int i = 0; i < Interface.CurrentControls.Length; i++)
            {
                //If we're using keyboard for this input
                if (Interface.CurrentControls[i].Method == Interface.ControlMethod.Keyboard)
                {
                    //Compare the current and previous keyboard states
                    //Only process if they are different
                    if (!Enum.IsDefined(typeof(Key), Interface.CurrentControls[i].Key)) continue;
                    if (e.Key == Interface.CurrentControls[i].Key & Interface.CurrentControls[i].Modifier == CurrentKeyboardModifier)
                    {

                        Interface.CurrentControls[i].AnalogState = 1.0;
                        Interface.CurrentControls[i].DigitalState = Interface.DigitalControlState.Pressed;
                        //Key repeats should not be added in non-game interface modes, unless they are Menu Up/ Menu Down commands
                        if (Game.CurrentInterface == Game.InterfaceType.Normal || Interface.CurrentControls[i].Command == Interface.Command.MenuUp || Interface.CurrentControls[i].Command == Interface.Command.MenuDown)
                        {
                            AddControlRepeat(i);
                        }
                    }
                }
            }
            BlockKeyRepeat = false;
            //Remember to reset the keyboard modifier after we're done, else it repeats.....
            CurrentKeyboardModifier = Interface.KeyboardModifier.None;
        }

        /// <summary>Called when a KeyUp event is generated</summary>
        internal static void keyUpEvent(object sender, KeyboardKeyEventArgs e)
        {
            //We don't need to check for modifiers on key up
            BlockKeyRepeat = true;
            //Traverse the controls array
            for (int i = 0; i < Interface.CurrentControls.Length; i++)
            {
                //If we're using keyboard for this input
                if (Interface.CurrentControls[i].Method == Interface.ControlMethod.Keyboard)
                {
                    //Compare the current and previous keyboard states
                    //Only process if they are different
                    if (!Enum.IsDefined(typeof(Key), Interface.CurrentControls[i].Key)) continue;
                    if (e.Key == Interface.CurrentControls[i].Key)
                    {
                        Interface.CurrentControls[i].AnalogState = 0.0;
                        Interface.CurrentControls[i].DigitalState = Interface.DigitalControlState.Released;
                        RemoveControlRepeat(i);
                    }
                }
            }
            BlockKeyRepeat = false;
        }
    }
}
