class Tooltip : Widget
{
    string text;

    float delay;

    float font_size;

    vector last_mouse_pos;

    virtual void() drawText =
    {
        vector xArea = getInternalDrawAreaX();
        vector yArea = getInternalDrawAreaY();

        drawstring([xArea.x, yArea.x, 0], text, [font_size, font_size, 0], color, opacity, 1);
    };

    virtual void() draw =
    {
        if (!text || !hovering) {
            return;
        }

        if (time < hoverStartTime + delay) {
            return;
        }

        //dprint(strcat(ftos(time), " < ", ftos(startTime), " + ", ftos(delay), "\n"));

        // Calculate position/size dynamically from mouse pos
        float strWidth = stringwidth(text, TRUE, [font_size, font_size, 0]);
        size.x = strWidth + (border_width * 2) + (padding.x * 2);
        size.y = font_size + (border_width * 2) + (padding.y * 2);

        drawBackgroundColor();
        drawBorder();
        drawText();
    };

    virtual float(Widget target) onHover =
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

    tooltip.delay = 0.6;
    tooltip.padding = [6, 4, 0];
    tooltip.background_color = [0.169, 0.165, 0.2];
    tooltip.background_color_hover = [0.169, 0.165, 0.2];
    tooltip.background_color_opacity = 1;
    tooltip.background_color_opacity_hover = 1;
    tooltip.border_color = [0, 1, 0];
    tooltip.border_color_hover = [0, 1, 0];
    tooltip.border_width = 1;
    tooltip.color = [0.85, 0.85, 0.85];
    tooltip.font_size = 5;
    tooltip.text = text;

    return tooltip;
}
