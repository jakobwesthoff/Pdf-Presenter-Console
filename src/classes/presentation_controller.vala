/**
 * Presentation Event controller
 *
 * This file is part of pdf-presenter-console.
 *
 * Copyright (C) 2010-2011 Jakob Westhoff <jakob@westhoffswelt.de>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

using GLib;

namespace org.westhoffswelt.pdfpresenter {
    /**
     * Controller handling all the triggered events/signals
     */
    public class PresentationController: Object {

        /**
         * Controllables which are registered with this presentation controller.
         */
        protected List<Controllable> controllables;

        /**
         * Ignore input events. Useful e.g. for editing notes.
         */
        protected bool ignore_input_events = false;

        /**
         * Notes for the slides
         */
        protected SlidesNotes notes;

        /**
         * Instantiate a new controller
         */
        public PresentationController(SlidesNotes notes) {
            this.controllables = new List<Controllable>();
            this.notes = notes;
        }

        /**
         * Handle keypresses to each of the controllables
         *
         * This seperate handling is needed because keypresses from any of the
         * window have implications on the behaviour of both of them. Therefore
         * this controller is needed to take care of the needed actions.
         *
         * There are no Vala bindings for gdk/gdkkeysyms.h
         * https://bugzilla.gnome.org/show_bug.cgi?id=551184
         *
         */
        public bool key_press( Gdk.EventKey key ) {
            if ( !ignore_input_events ) {
                switch( key.keyval ) {
                    case 0xff0d: /* Return */
                    case 0xff53: /* Cursor right */
                    case 0xff56: /* Page down */
                    case 0x020:  /* Space */
                        this.controllables_next_page();
                    break;
                    case 0x06e:  /* n */
                        this.controllables_jump10();
                    break;
                    case 0xff51: /* Cursor left */
                    case 0xff55: /* Page Up */
                        this.controllables_previous_page();
                    break;
                    case 0xff08: /* Backspace */
                    case 0x070:
                        this.controllables_back10();
                    break;
                    case 0xff1b: /* Escape */
                    case 0x071:  /* q */
                        this.notes.save_to_disk();
                        Gtk.main_quit();
                    break;
                    case 0xff50: /* Home */
                        this.controllables_reset();
                    break;
                    case 0x062: /* b*/
                        this.controllables_fade_to_black();
                    break;
                    case 0x065: /* e */
                        this.controllables_edit_note();
                    break;
                    case 0x073: /* s */
                        this.notes.save_to_disk();
                    break;
                    case 0x067: /* g */
                        this.controllables_ask_goto_page();
                    break;
                }
                return true;
            } else {
                return false;
            }
        }

        /**
         * Handle mouse clicks to each of the controllables
         */
        public bool button_press( Gdk.EventButton button ) {
            if ( !ignore_input_events && button.type ==
                    Gdk.EventType.BUTTON_PRESS ) {
                // Prevent double or triple clicks from triggering additional
                // click events
                switch( button.button ) {
                    case 1: /* Left button */
                        this.controllables_next_page();
                    break;
                    case 3: /* Right button */
                        this.controllables_previous_page();
                    break;
                }
                return true;
            } else {
                return false;
            }
        }

        /**
         * Notify each of the controllables of mouse scrolling
         */
        public void scroll( Gdk.EventScroll scroll ) {
            
            switch( scroll.direction ) {
                case Gdk.ScrollDirection.UP: /* Scroll up */
                case Gdk.ScrollDirection.LEFT: /* Scroll left */ 
                    this.controllables_previous_page();
                break;
                case Gdk.ScrollDirection.DOWN: /* Scroll down */
                case Gdk.ScrollDirection.RIGHT: /* Scroll right */ 
                    this.controllables_next_page();
                break;
            }
        }

        /**
         * A request to change the page has been issued
         */
        public void page_change_request( int page_number ) {
            this.controllables_goto_page( page_number );
        }

        /**
         * Set the state of ignote_input_events
         */
        public void set_ignore_input_events( bool v ) {
            ignore_input_events = v;
        }

        /**
         * Register a new Controllable instance on this controller. 
         *
         * On success true is returned, in case the controllable has already been
         * registered false is returned.
         */
        public bool register_controllable( Controllable controllable ) {
            if ( this.controllables.find( controllable ) != null ) {
                // The controllable has already been added.
                return false;
            }

            controllable.set_controller( this );
            this.controllables.append( controllable );
            
            return true;
        }
        
        /**
         * Move all registered controllables to the next page
         */
        protected void controllables_next_page() {
            foreach( Controllable c in this.controllables ) {
                c.next_page();
            }
        }

        /**
         * Move all registered controllables 10 pages forward
         */
        protected void controllables_jump10() {
            foreach( Controllable c in this.controllables ) {
                c.jump10();
            }
        }

        /**
         * Move all registered controllables to the previous page
         */
        protected void controllables_previous_page() {
            foreach( Controllable c in this.controllables ) {
                c.previous_page();
            }
        }

        /**
         * Go back 10 pages in all registered controllables
         */
        protected void controllables_back10() {
            foreach( Controllable c in this.controllables ) {
                c.back10();
            }
        }

        /**
         * Reset all registered controllables to their initial state
         */
        protected void controllables_reset() {
            foreach( Controllable c in this.controllables ) {
                c.reset();
            }
        }

        /**
         * Have all controllables display a certain page
         */
        protected void controllables_goto_page( int page_number ) {
            foreach( Controllable c in this.controllables ) {
                c.goto_page( page_number );
            }
        }

        /**
         * public interface for the above function
         */
        public void goto_page( int page_number ) {
            controllables_goto_page(page_number);
        }

        /**
         * Fill the presentation display with black
         */
        protected void controllables_fade_to_black() {
            foreach( Controllable c in this.controllables ) {
                c.fade_to_black();
            }
        }

        /**
         * Edit note for current slide.
         */
        protected void controllables_edit_note() {
            foreach( Controllable c in this.controllables ) {
                c.edit_note();
            }
        }

        /**
         * Ask for the page to jump to
         */
        protected void controllables_ask_goto_page() {
            foreach( Controllable c in this.controllables ) {
                c.ask_goto_page();
            }
        }
    }
}
