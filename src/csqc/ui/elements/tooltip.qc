class Tooltip : UIElement 
{
    string text;

    float delay;

    float font_size;

    vector last_mouse_pos;

    virtual void() drawText =
    {
        vector xArea = getInternalDrawAreaX();
        vector yArea = getInternalDrawAreaY();

        drawstring([xArea.x, yArea.x, 0], text, [font_size, font_size, 0], color, opacity, 0);
    };

    virtual void() draw =
    {
        if (!text || !hovering) {
            return;
        }

        if (time < hoverStartTime + delay) {
            return;
        }

        // Calculate position/size dynamically from mouse pos
        float strWidth = stringwidth(text, TRUE, [font_size, font_size, 0]);
        size.x = strWidth + (border_width * 2) + padding[1] + padding[3];
        size.y = font_size + (border_width * 2) + padding[0] + padding[2];

        drawBackgroundColor();
        drawBorder();
        drawText();
    };

    virtual float(UIElement target) onHover =
    {
        if (mousePosition != last_mouse_pos) {
            hoverStartTime = time;
        }

        last_mouse_pos = mousePosition;

        return FALSE;
    };
};

Tooltip(string text) NewTooltip =
{
    Tooltip tooltip = spawn(Tooltip);

    tooltip.ignore_overflow = TRUE;
    tooltip.delay = 0.6;
    tooltip.setPadding(4, 6, 4, 6);
    tooltip.background_color = [0.1, 0.1, 0.1];
    tooltip.background_color_hover = [0.1, 0.1, 0.1];
    tooltip.background_color_opacity = 1;
    tooltip.background_color_opacity_hover = 1;
    tooltip.color = [0.85, 0.85, 0.85];
    tooltip.font_size = 5;
    tooltip.text = text;

    return tooltip;
}
