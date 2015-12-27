/**
 * Pdf renderer
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
using Gdk;
using Cairo;

namespace org.westhoffswelt.pdfpresenter {
    /**
     * Pdf slide renderer
     */
    public class Renderer.Pdf: Renderer.Base, Renderer.Caching
    {
        /**
         * The scaling factor needed to render the pdf page to the desired size.
         */
        protected double scaling_factor;

        /**
         * Cache store to be used
         */
        protected Renderer.Cache.Base cache = null;

        protected Options.LatexBeamerNotes latexbeamernotes = Options.LatexBeamerNotes.NONE;

        /**
         * Base constructor taking a pdf metadata object as well as the desired
         * render width and height as parameters.
         *
         * The pdf will always be rendered to fill up all available space. If
         * the proportions of the rendersize do not fit the proportions of the
         * pdf document the renderspace is filled up completely cutting of a
         * part of the pdf document.
         */
        public Pdf( Metadata.Pdf metadata, int width, int height ) {
            base( metadata, width, height );

            // Calculate the scaling factor needed.
            this.scaling_factor = Math.fmax(
                width / metadata.get_page_width(),
                height / metadata.get_page_height()
            );
        }

        /**
         * Set cache store to use
         */
        public void set_cache( Renderer.Cache.Base cache ) {
            this.cache = cache;
        }

        /**
         * Retrieve the currently used cache engine
         */
        public Renderer.Cache.Base get_cache() {
            return this.cache;
        }

        public void set_latexbeamernotes(Options.LatexBeamerNotes notes)
        {
            this.latexbeamernotes = notes;
        }

        /**
         * Render the given slide_number to a Gdk.Pixmap and return it.
         *
         * If the requested slide is not available an
         * RenderError.SLIDE_DOES_NOT_EXIST error is thrown.
         */
        public override Gdk.Pixmap render_to_pixmap( int slide_number )
            throws Renderer.RenderError {

            var metadata = this.metadata as Metadata.Pdf;

            // Check if a valid page is requested, before locking anything.
            if ( slide_number < 0 || slide_number >= metadata.get_slide_count() ) {
                throw new Renderer.RenderError.SLIDE_DOES_NOT_EXIST( "The requested slide '%i' does not exist.", slide_number );
            }

            // If caching is enabled check for the page in the cache
            if ( this.cache != null ) {
                Gdk.Pixmap cache_content;
                if ( ( cache_content = this.cache.retrieve( slide_number ) ) != null ) {
                    return cache_content;
                }
            }

            // Retrieve the Poppler.Page for the page to render
            MutexLocks.poppler.lock();
            var page = metadata.get_document().get_page( slide_number );
            MutexLocks.poppler.unlock();

            // A lot of Pdfs have transparent backgrounds defined. We render
            // every page before a white background because of this.
            Pixmap pixmap = new Pixmap( null, this.width, this.height, 24 );
            Context cr = Gdk.cairo_create( pixmap );

            cr.set_source_rgb( 255, 255, 255 );
            cr.rectangle( 0, 0, this.width, this.height );
            cr.fill();

            // Latex beamer notes: Render correct side of the page
            if(this.latexbeamernotes == Options.LatexBeamerNotes.LEFT)
                cr.translate(-this.width,0);

            cr.scale(this.scaling_factor, this.scaling_factor);



            MutexLocks.poppler.lock();
            page.render(cr);
            MutexLocks.poppler.unlock();

            // If the cache is enabled store the newly rendered pixmap
            if ( this.cache != null ) {
                this.cache.store( slide_number, pixmap );
            }

            return pixmap;
        }
    }
}
