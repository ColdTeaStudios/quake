class MenuController
{
    Menu current;
    Menu last;

    // Linked list of all menus.
    Menu list;

    virtual void() registerMenus =
    {
        // gross, but manually register menus here
    };

    void() MenuController
    {
        registerMenus();
    };

    virtual float(string menuName) setMenu =
    {
        if (!menuName) {
            last = current;
            current = (Menu) world;

            return TRUE;
        }

        Menu menu = list;
        while (menu != world) {
            if (menu.name == menuName) {
                last = current;
                current = menu;

                return TRUE;
            }
            menu = menu.next;
        }

        return FALSE;
    };

    virtual float(float evType, float scanCode, float char) handleInput =
    {
        if (!current) {
            return FALSE;
        }

        return current.handleInput(evType, scanCode, char);
    };

    virtual void() draw =
    {
        if (current != world) {
            current.draw();
        }
    };
};
