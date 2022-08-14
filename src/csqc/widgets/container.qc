class Container : Widget
{
    Widget children;

    virtual float(float evType, float scanCode, float char) handleInput =
    {
        float handled = FALSE;

        Widget child = children;
        while (child != world && !handled) {
            // TODO actual event handling

            child = children.next_element;
        }

        return handled;
    };

    virtual void() draw =
    {
        drawBackgroundColor();
        drawBackgroundImage();
        drawBorder();

        Widget child = children;
        while (child != world) {
            child.draw();
            child = child.next_element;
        }
    };

    virtual void(Widget widget) addWidget =
    {
        if (children == world) {
            children = widget;
            widget.first_element = widget;
        } else {
            Widget child = children;
            while (child.next_element != world) {
                child = child.next_element;
            }

            widget.prev_element = child;
            widget.first_element = children;
            child.next_element = widget;
        }

        widget.parent = this;
    };
};
