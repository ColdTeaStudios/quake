class Tooltip : Widget
{
    string text;

    float hovering;
    float hoverTime;

    float delay;

    float font_size;

    void() Tooltip =
    {
        delay = 0.5;
        padding = [8, 4, 0];
        background_color = [0.169, 0.165, 0.2];
        border_color = [0, 1, 0];
        border_width = 1;
        color = [0.85, 0.85, 0.85];
        font_size = 8;
    };

    virtual void() drawText =
    {
        vector xArea = getInternalDrawAreaX();
        vector yArea = getInternalDrawAreaY();

        drawstring([xArea.x, yArea.x, 0], text, [font_size, font_size, 0], color, opacity, 1);
    };

    virtual void() draw =
    {
        if (!text) {
            return;
        }

        if (hoverTime < delay) {
            return;
        }

        // Calculate position/size dynamically from mouse pos
        float strWidth = stringwidth(text, TRUE, [font_size, font_size, 0]);
        size.x = strWidth + (border_width * 2) + (padding.x * 2);
        size.y = font_size + (border_width * 2) + (padding.y * 2);

        drawBackgroundColor();
        drawBorder();
        drawText();
    };

    virtual void() think =
    {
        hoverTime += 0.1;
    };

    virtual float() hover =
    {
        hovering = TRUE;

        return TRUE;
    };

    virtual float() stopHover =
    {
        hovering = FALSE;
        hoverTime = 0;

        return TRUE;
    };
};
