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

    virtual void() draw =
    {
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
