enum backgroundSizeMode
{
    // backgroundSize in pixels (x, y)
    W_BG_SZ_PIXELS,
    // backgroundSize in % (x, y)
    W_BG_SZ_PCT,
    // Crop, so the smallest image axis fits the widget, the excess in the other axis will be cropped
    W_BG_SZ_COVER,
    // Stretch the image to the container x/y
    W_BG_SZ_SCALE = 3
};

class Widget
{
    entity parent;

    vector position;
    vector size;

    vector padding; // X/Y, no separate left/right or top/bottom
    vector margin;  // X/Y, no separate left/right or top/bottom

	Widget first_element;
	Widget next_element;
	Widget prev_element;

    vector border_color;
    vector border_color_hover;
    float border_width;

    vector color; // foreground color
    vector color_hover;

    vector background_color; // background_color, will be drawn before image
    float background_color_opacity; // 0.0 - 1.0

    vector background_color_hover;
    float background_color_opacity_hover; // 0.0 - 1.0

    string background_image;
    float background_image_opacity;
    vector background_size;
    backgroundSizeMode background_size_mode;
    float background_repeat; // bool
    float background_image_hover_opacity;

    float active; // bool
    float opacity; // 0.0 - 1.0
    float opacity_hover; // 0.0 - 1.0

    // bool, if FALSE, widget will not capture mouse events (hover, click), useful for drawing overlays etc.
    float mouse_events;

    float draggable; // bool

    Widget tooltip;

    void() Widget =
    {
        dprint("Widget constructor called\n");
        // Set some basic defaults
        color = [1, 1, 1];
        color_hover = [1, 1, 1];
        background_size_mode = W_BG_SZ_COVER;
        opacity = 1.0;
        opacity_hover = 1.0;
        mouse_events = TRUE;
        draggable = FALSE;
    };

    virtual float() isMouseOver = 
    {
        if (!mouse_events) {
            return FALSE;
        }

        vector temp = position;
        if(parent != world) {
            temp += parent.origin;
        }

        if(mousePosition_x >= temp_x && mousePosition_x <= temp_x + size_x
            && mousePosition_y >= temp_y && mousePosition_y <= temp_y + size_y)
        {
            return TRUE;
        }

        return FALSE;
    };

    virtual void() drawBorder =
    {
        vector temp = position;
        if(parent != world) {
            temp += parent.origin;
        }

        vector tl = temp;

        vector tr = temp;
        tr.x += size.x;

        vector br = temp;
        br.x += size.x;
        br.y += size.y;

        vector bl = temp;
        bl.y += size.y;

        float hovering = isMouseOver();

        drawline(
            border_width,
            tl,
            tr,
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            1
        );

        drawline(
            border_width,
            tr,
            br,
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            1
        );

        drawline(
            border_width,
            br,
            bl,
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            1
        );

        drawline(
            border_width,
            bl,
            tl,
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            1
        );
    };

    virtual void() drawBackgroundColor =
    {
        vector tmpPos = position;
        if (parent != world) {
            tmpPos += parent.origin;
        }

        vector tmpSize = size;
        if (border_width > 0) {
            tmpPos.x += border_width;
            tmpPos.y += border_width;
            tmpSize.x -= border_width*2;
            tmpSize.y -= border_width*2;
        }

        float hovering = isMouseOver();

        drawfill(
            tmpPos,
            tmpSize,
            hovering ? background_color_hover : background_color,
            hovering ? background_color_opacity_hover * opacity : background_color_opacity * opacity,
            1
        );
    };

    virtual void() drawBackgroundImage =
    {
        if (!background_image) {
            return;
        }

        vector tmpPos = position;
        if (parent != world) {
            tmpPos += parent.origin;
        }

        vector tmpSize = size;
        if (border_width > 0) {
            tmpPos.x += border_width;
            tmpPos.y += border_width;
            tmpSize.x -= border_width*2;
            tmpSize.y -= border_width*2;
        }

        if (tmpSize.x <= 0 || tmpSize.y <= 0) {
            return;
        }

        float hovering = isMouseOver();

        drawsetcliparea(tmpPos.x, tmpPos.y, tmpSize.x, tmpSize.y);

        if (background_size_mode == W_BG_SZ_SCALE) {
            drawpic(
                tmpPos,
                background_image,
                tmpSize,
                '1 1 1',
                hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                1
            );
        } else if (background_size_mode == W_BG_SZ_COVER) {
            vector imgSize = draw_getimagesize(background_image);

            if (imgSize.x <= 0 || imgSize.y <= 0) {
                dprint(strcat("\b[CSQC]\b No imgSize for img: ", background_image, "\n"));
                return;
            }

            float imgRatio = (imgSize.y / imgSize.x);
            float ctRatio = (tmpSize.y / tmpSize.x);

            vector drawSize;

            if (ctRatio > imgRatio) {
                drawSize.y = tmpSize.y;
                drawSize.x = (tmpSize.y / imgRatio);
            } else {
                drawSize.x = tmpSize.x; 
                drawSize.y = (tmpSize.x / imgRatio);
            }

            drawpic(
                tmpPos,
                background_image,
                drawSize,
                '1 1 1',
                hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                1
            );
        } else if (background_size_mode == W_BG_SZ_PIXELS) {
            float xRepeats = 1;
            float yRepeats = 1;

            // Use the specified background image size, if none specified try to use the image dimensions.
            imgSize = background_size;
            if (imgSize.x <= 0 || imgSize.y <= 0) {
                imgSize = draw_getimagesize(background_image);
            }

            if (imgSize.x <= 0 || imgSize.y <= 0) {
                dprint(strcat("\b[CSQC]\b No imgSize for img: ", background_image, "\n"));
                return;
            }

            if (background_repeat) {
                xRepeats = ceil(tmpSize.x / imgSize.x);
                yRepeats = ceil(tmpSize.y / imgSize.y);
            }

            for (float y = 0; y < yRepeats; y++) {
                for (float x = 0; x < xRepeats; x++) {
                    vector repeatPos = tmpPos;
                    repeatPos.x += imgSize.x * x;
                    repeatPos.y += imgSize.y * y;

                    drawpic(
                        repeatPos,
                        background_image,
                        imgSize,
                        '1 1 1',
                        hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                        1
                    );
                }
            }
        } else if (background_size_mode == W_BG_SZ_PCT) {
            if (background_size.x <= 0 || background_size.y <= 0) {
                dprint("\b[CSQC]\b No background_size for PCT scale\n");
                return;
            }

            float xSize = tmpSize.x * (background_size.x / 100);
            float ySize = tmpSize.y * (background_size.y / 100);

            xRepeats = background_repeat ? ceil(tmpSize.x / xSize) : 1;
            yRepeats = background_repeat ? ceil(tmpSize.y / ySize) : 1;

            for (float y = 0; y < yRepeats; y++) {
                for (float x = 0; x < xRepeats; x++) {
                    vector repeatPos = tmpPos;
                    repeatPos.x += xSize * x;
                    repeatPos.y += ySize * y;

                    drawpic(
                        repeatPos,
                        background_image,
                        [xSize, ySize, 0],
                        '1 1 1',
                        hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                        1
                    );
                }
            }
        }

        drawresetcliparea();
    };

    virtual void() draw =
    {
        drawBackgroundColor();
        drawBackgroundImage();
        drawBorder();
    };

    virtual var float(Widget target) onClick;

    virtual var float(Widget target) onDragStart;

    virtual var float(Widget target) onDragFinish;

    virtual var float(Widget target) onHover;

    virtual var float(Widget target) onStopHover;

    virtual float() click =
    {
        if (!mouse_events) {
            return FALSE;
        }

        if (!onClick) {
            return FALSE;
        }

        return onClick(this);
    };

    virtual float() dragStart =
    {
        if (!mouse_events || !draggable) {
            return FALSE;
        }

        if (!onDragStart) {
            return FALSE;
        }

        return onDragStart(this);
    };

    virtual float() dragEnd =
    {
        if (!mouse_events || !draggable) {
            return FALSE;
        }

        if (!onDragFinish) {
            return FALSE;
        }

        return onDragFinish(this);
    };

    virtual float() hover =
    {
        if (!mouse_events) {
            return FALSE;
        }

        if (tooltip != world) {
            tooltip.hover();
        }

        if (!onHover) {
            return FALSE;
        }

        return onHover(this);
    };

    virtual float() stopHover =
    {
        if (!mouse_events) {
            return FALSE;
        }

        if (tooltip != world) {
            tooltip.stopHover();
        }

        if (!onStopHover) {
            return FALSE;
        }

        return onStopHover(this);
    };

    /**
     * Returns the internal draw area (X axis) after factoring in border & padding.
     * This is similar to CSS border-box box-sizing.
     * x: startX, y: startX + available width, z: unused
     * Minimum values will be clamped to 0
     */ 
    virtual vector() getInternalDrawAreaX =
    {
        if (size.x <= 0 || size.y <= 0) {
            return [0, 0, 0];
        }

        vector tmpPos = position;
        if (parent != world) {
            tmpPos += parent.origin;
        }

        tmpPos = [tmpPos.x, tmpPos.x + size.x, 0];

        if (this.border_width > 0) {
            tmpPos.x += border_width;
            tmpPos.y -= border_width * 2;
        }

        if (this.padding.x > 0) {
            tmpPos.x += padding.x;
            tmpPos.y -= padding.x * 2;
        }

        if (tmpPos.x > tmpPos.y) {
            return [0, 0, 0];
        }

        return tmpPos;
    };

    /**
     * Returns the internal draw area (X axis) after factoring in border & padding.
     * This is similar to CSS border-box box-sizing.
     * x: startY, y: startY + available height, z: unused
     * Minimum values will be clamped to 0
     */ 
    virtual vector() getInternalDrawAreaY =
    {
        if (size.x <= 0 || size.y <= 0) {
            return [0, 0, 0];
        }

        vector tmpPos = position;
        if (parent != world) {
            tmpPos += parent.origin;
        }

        tmpPos = [tmpPos.x, tmpPos.x + size.x, 0];

        if (this.border_width > 0) {
            tmpPos.x += border_width;
            tmpPos.y -= border_width * 2;
        }

        if (this.padding.y > 0) {
            tmpPos.x += padding.y;
            tmpPos.y -= padding.y * 2;
        }

        if (tmpPos.x > tmpPos.y) {
            return [0, 0, 0];
        }

        return tmpPos;
    };
};
