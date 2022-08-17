enum backgroundSizeMode
{
    // backgroundSize in pixels (x, y)
    W_BG_SZ_PIXELS,
    // backgroundSize in % (x, y)
    W_BG_SZ_PCT,
    // Crop, so the smallest image axis fits the element, the excess in the other axis will be cropped
    W_BG_SZ_COVER,
    // Stretch the image to the container x/y
    W_BG_SZ_SCALE = 3
};

enum positionMode
{
    // The parent will dictate the position based on the flow model
    W_POS_STATIC,
    // will be positioned absolute (in px) and exist 'outside' of the parent flow
    W_POS_ABSOLUTE,
    // The element will remain in the same place on the viewport, positioned relative to the nearest parent Container.
    // This is useful for elements that you want to 'remain' while scrolling containers etc.
    W_POS_FIXED = 2,
};

enum scrollMode
{
    // Elements that overflow will be hidden. This is the default.
    W_SCR_HIDDEN,
    // Elements will be visible if drawn outside of this element, this is useful for custom image borders for example.
    W_SCR_VISIBLE,
    // Elements will overflow, causing the container to render a scrollbar. Only `Container`s can scroll.
    W_SCR_SCROLL,
    W_SCR_SCROLL_X,
    W_SCR_SCROLL_Y = 4,
};

class UIElement
{
    UIElement parent;

    // If you set a position with W_POS_RELATIVE, it will be ignored. Use absolute if you want manual positioning.
    vector position;

    positionMode position_mode;

    scrollMode scroll_mode;

    vector size;

    float padding[4]; // Top Right Bottom Left
    float margin[4]; // Top Right Bottom Left

	UIElement first_element; // First sibling on the current level
	UIElement next_element; // Next sibling on the current level
	UIElement prev_element; // Prev sibling on the current level

    UIElement children; // Child elements

    float hovering;
    float active; // bool
    float hoverStartTime;

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

    float opacity; // 0.0 - 1.0
    float opacity_hover; // 0.0 - 1.0

    // bool, if FALSE, element will not capture mouse events (hover, click), useful for drawing overlays etc.
    float mouse_events;

    // bool, if TRUE will allow the element to draw outside of any inherited bounds, e.g tooltips
    float ignore_overflow;

    float draggable; // bool

    UIElement tooltip;

    void() UIElement =
    {
        // Set some basic defaults
        color = [1, 1, 1];
        color_hover = [1, 1, 1];
        background_size_mode = W_BG_SZ_COVER;
        opacity = 1.0;
        opacity_hover = 1.0;
        mouse_events = TRUE;
        draggable = FALSE;
        position_mode = W_POS_STATIC;
        scroll_mode = W_SCR_HIDDEN;
    };

    virtual vector() getAbsolutePos =
    {
        // Haha grosssssss
        if (this.classname == "Tooltip") {
            return [mousePosition.x, mousePosition.y - size.y];
        }

        vector tmpPos = position;
        UIElement p = parent;
        while (p != world) {
            tmpPos += p.position;
            p = p.parent;
        }

        return tmpPos;
    };

    // This is a temp field used for stepping through the tree correctly to drill down to this element (top-down).
    UIElement next_chain;

    // Returns available [xpos1, xpos2, 0]
    virtual vector() getElementBoundsX =
    {
        // Haha grosssssss
        if (this.classname == "Tooltip") {
            return [mousePosition.x, mousePosition.x + size.x];
        }

        vector extent = [position.x, 0];

        // Get the absolute position (bounds) of this element.
        UIElement p = parent;
        UIElement root = this;
        while (p != world) {
            extent[0] += p.position.x;
            p.next_chain = root;
            root = p;
            p = p.parent;
        }

        extent[1] = extent[0] + size.x;

        // Traverse the tree again, top-down, and limit our bounds by any parent containers
        float pX = 0;
        p = root;
        while (p != this) {
            pX += p.position.x;

            if (pX > extent[0]) {
                extent[0] = pX;
            }

            if (pX + p.size.x < extent[1]) {
                extent[1] = pX + p.size.x;
            }

            p = p.next_chain;
        }

        return extent;
    };

    // Returns available [ypos1, ypos2, 0]
    virtual vector() getElementBoundsY =
    {
        // Haha grosssssss
        if (this.classname == "Tooltip") {
            return [mousePosition.y - size.y, mousePosition.y];
        }

        vector extent = [position.y, 0];

        // Get the absolute position (bounds) of this element.
        UIElement p = parent;
        UIElement root = this;
        while (p != world) {
            extent[0] += p.position.y;
            p.next_chain = root;
            root = p;
            p = p.parent;
        }

        extent[1] = extent[0] + size.y;

        // Traverse the tree again, top-down, and limit our bounds by any parent containers
        float pY = 0;
        p = root;
        while (p != this) {
            pY += p.position.y;

            if (pY > extent[0]) {
                extent[0] = pY;
            }

            if (pY + p.size.y < extent[1]) {
                extent[1] = pY + p.size.y;
            }

            p = p.next_chain;
        }

        return extent;
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

        vector boundsX = getElementBoundsX();

        boundsX[0] += border_width;
        boundsX[1] -= border_width;

        boundsX[0] += padding[3];
        boundsX[1] -= padding[1];

        if (boundsX[0] >= boundsX[1]) {
            return [0, 0, 0];
        }

        return boundsX;
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

        vector boundsY = getElementBoundsY();

        boundsY[0] += border_width;
        boundsY[1] -= border_width;

        boundsY[0] += padding[0];
        boundsY[1] -= padding[2];

        if (boundsY[0] >= boundsY[1]) {
            return [0, 0, 0];
        }

        return boundsY;
    };

    virtual void() drawBorder =
    {
        vector temp = getAbsolutePos();

        vector boundsX = getElementBoundsX();
        vector boundsY = getElementBoundsY();

        if (!ignore_overflow) {
            drawsetcliparea(boundsX[0], boundsY[0], boundsX[1] - boundsX[0], boundsY[1] - boundsY[0]);
        }

        if (border_color[0] > 1.0) {
            border_color[0] /= 255;
        }
        if (border_color[1] > 1.0) {
            border_color[1] /= 255;
        }
        if (border_color[2] > 1.0) {
            border_color[2] /= 255;
        }
        if (border_color_hover[0] > 1.0) {
            border_color_hover[0] /= 255;
        }
        if (border_color_hover[1] > 1.0) {
            border_color_hover[1] /= 255;
        }
        if (border_color_hover[2] > 1.0) {
            border_color_hover[2] /= 255;
        }

        drawfill(
            temp,
            [size.x, border_width],
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            0
        );

        drawfill(
            [temp.x + size.x - border_width, temp.y],
            [border_width, size.y],
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            0
        );

        drawfill(
            [temp.x, temp.y + size.y - border_width],
            [size.x, border_width],
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            0
        );

        drawfill(
            [temp.x, temp.y],
            [border_width, size.y],
            hovering ? border_color_hover : border_color,
            hovering ? opacity_hover * opacity : opacity,
            0
        );

        if (!ignore_overflow) {
            drawresetcliparea();
        }
    };

    virtual void() drawBackgroundColor =
    {
        vector tmpPos = getAbsolutePos();

        vector boundsX = getElementBoundsX();
        vector boundsY = getElementBoundsY();

        if (!ignore_overflow) {
            drawsetcliparea(boundsX[0], boundsY[0], boundsX[1] - boundsX[0], boundsY[1] - boundsY[0]);
        }

        vector tmpSize = size;
        if (border_width > 0) {
            tmpPos.x += border_width;
            tmpPos.y += border_width;
            tmpSize.x -= border_width*2;
            tmpSize.y -= border_width*2;
        }

        drawfill(
            tmpPos,
            tmpSize,
            hovering ? background_color_hover : background_color,
            hovering ? background_color_opacity_hover * opacity : background_color_opacity * opacity,
            0
        );

        if (!ignore_overflow) {
            drawresetcliparea();
        }
    };

    virtual void() drawBackgroundImage =
    {
        if (!background_image) {
            return;
        }

        vector tmpPos = getAbsolutePos();
        vector boundsX = getElementBoundsX();
        vector boundsY = getElementBoundsY();

        vector tmpSize = size;
        if (border_width > 0) {
            tmpSize.x -= border_width*2;
            tmpSize.y -= border_width*2;
        }

        if (tmpSize.x <= 0 || tmpSize.y <= 0) {
            return;
        }

        drawsetcliparea(tmpPos.x, tmpPos.y, tmpSize.x, tmpSize.y);

        if (background_size_mode == W_BG_SZ_SCALE) {
            drawpic(
                tmpPos,
                background_image,
                tmpSize,
                [1, 1, 1],
                hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                0
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
                [1, 1, 1],
                hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                0
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
                        [1, 1, 1],
                        hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                        0
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
                        [1, 1, 1],
                        hovering ? background_image_hover_opacity * opacity : background_image_opacity * opacity,
                        0
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

        if (tooltip) {
            tooltip.draw();
        }
    };

    virtual var float(UIElement target) onClick;

    virtual var float(UIElement target) onRightClick;

    virtual var float(UIElement target) onKeyDown;

    virtual var float(UIElement target) onKeyUp;

    virtual var float(UIElement target) onDragStart;

    virtual var float(UIElement target) onDragFinish;

    virtual var float(UIElement target) onHover;

    virtual var float(UIElement target) onStopHover;

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

        hovering = TRUE;
        if (!hoverStartTime) {
            hoverStartTime = time;
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

        hovering = FALSE;
        hoverStartTime = 0;

        if (tooltip != world) {
            tooltip.stopHover();
        }

        if (!onStopHover) {
            return FALSE;
        }

        return onStopHover(this);
    };

    virtual float(float evType, float scanCodeX, float charY) handleInput =
    {
        //dprint(strcat("evType: ", ftos(evType), "   ", "scanCode: ", ftos(scanCodeX), "\n"));
        // We need to get the extent, as we don't want to push events to elements where el.size has overflowed
        // beyond the scope of the container (TODO: unless overflow is set to visible).
        vector boundsX = getElementBoundsX();
        vector boundsY = getElementBoundsY();
        if (boundsX[1] <= boundsX[0] || boundsY[1] <= boundsY[0]) {
            return FALSE;
        }

        // We want events to bubble up (specificity first), rather than drill down, so check if any children elements
        // handle our event before we do.
        if (children != world) {
            UIElement child = children;
            while (child != world) {
                if (child.handleInput(evType, scanCodeX, charY)) {
                    return TRUE;

                    // TODO fixme hover below?
                }

                child = child.next_element;
            }
        }

        // Handle mouse move events
        if (evType == IE_MOUSEABS) {
            if (mousePosition.x >= boundsX[0] && mousePosition.x <= boundsX[1]
                && mousePosition.y >= boundsY[0] && mousePosition.y <= boundsY[1]) {
                hover();
            } else {
                if (hovering) {
                    stopHover();
                }
            }

            // Allow hover at every point in the tree, so return false.
            return FALSE;
        }

        if (evType == IE_KEYDOWN) {
            if (scanCodeX == K_MOUSE1) {
                if (hovering && onClick) {
                    onClick(this);
                    return TRUE;
                }
            }
        }

        return FALSE;
    };

    virtual void(float t, float r, float b, float l) setPadding =
    {
        padding[0] = t;
        padding[1] = r;
        padding[2] = b;
        padding[3] = l;
    };

    virtual void(float t, float r, float b, float l) setMargin =
    {
        margin[0] = t;
        margin[1] = r;
        margin[2] = b;
        margin[3] = l;
    };
};
