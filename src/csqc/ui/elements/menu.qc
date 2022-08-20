class Menu
{
    // linked list
    Menu next;

    // Must be unique, used for referencing
    string name;

    // Linked list of children
    UIElement children;

    virtual float(float evType, float scanCodeX, float charY) handleInput =
    {
        float handled = FALSE;

        UIElement child = children;
        while (child != world && !handled) {
            handled = child.handleInput(evType, scanCodeX, charY);
            child = children.next_element;
        }

        return handled;
    };

    // Hehe.
    virtual void() draw =
    {
        UIElement child = children;
        while (child != world) {
            child.draw();
            UIElement c2 = child.children;
            while (c2 != world) {
                c2.draw();
                UIElement c3 = c2.children;
                while (c3 != world) {
                    c3.draw();
                    UIElement c4 = c3.children;
                    while (c4 != world) {
                        c4.draw();
                        UIElement c5 = c4.children;
                        while (c5 != world) {
                            c5.draw();
                            c5 = c5.next_element;
                        }
                        c4 = c4.next_element;
                    }
                    c3 = c3.next_element;
                }
                c2 = c2.next_element;
            }
            child = child.next_element;
        }
    };

    virtual void(UIElement el) addElement =
    {
        if (children == world) {
            children = el;
            return;
        }

        UIElement child = children;
        while (child.next_element != world) {
            child = child.next_element;
        }

        child.next_element = el;
    };

    virtual void() onOpen = {};
};
