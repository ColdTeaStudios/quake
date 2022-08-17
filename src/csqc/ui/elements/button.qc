// A button is just a UIElement with a label and default hover settings!
class Button : UIElement
{
    string text;
    float font_size;

    void() Button =
    {
        dprint("Button constructor called\n");
        font_size = 8;
        text = "Button";
        background_color = [0.169, 0.165, 0.2];
        background_color_hover = [0.169, 0.165, 0.2];
        background_color_opacity = 1.0;
        background_color_opacity_hover = 1.0;
        border_color = [0.7, 0.7, 0.7];
        border_color_hover = [0.85, 0.85, 0.85];
        border_width = 1;
    };

    virtual void() drawText =
    {
        // TODO center text from strWidth
        float strWidth = stringwidth(text, TRUE, [font_size, font_size, 0]);
        vector xArea = getInternalDrawAreaX();
        vector yArea = getInternalDrawAreaY();

        drawsetcliparea(xArea.x, yArea.x, xArea.y - xArea.x, yArea.y - yArea.x);

        drawstring(
            [xArea.x, yArea.x, 0],
            text,
            [font_size, font_size, 0],
            hovering ? color_hover : color,
            hovering ? opacity_hover : opacity,
            1
        );

        drawresetcliparea();
    };

    virtual void() draw =
    {
        drawBackgroundColor();
        drawBorder();
        drawText();


        if (tooltip) {
            tooltip.draw();
        }
    };
};
