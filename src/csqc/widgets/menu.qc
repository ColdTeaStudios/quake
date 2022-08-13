class Menu
{
    // linked list
    Menu next;

    // Must be unique, used for referencing
    string name;

    // Linked list of children
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
        } else {
            Widget child = children;
            while (child.next_element != world) {
                child = child.next_element;
            }

            child.next_element = widget;
        }
    };
};
