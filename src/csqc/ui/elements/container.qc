class Container : UIElement
{
    virtual void() draw =
    {
        drawBackgroundColor();
        drawBackgroundImage();
        drawBorder();

        UIElement child = children;
        while (child != world) {
            child.draw();
            child = child.next_element;
        }
    };

    virtual void(UIElement el) addElement =
    {
        if (children == world) {
            children = el;
            el.first_element = el;
        } else {
            UIElement child = children;
            while (child.next_element != world) {
                child = child.next_element;
            }

            el.prev_element = child;
            el.first_element = children;
            child.next_element = el;
        }

        el.parent = this;
    };
};
