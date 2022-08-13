class MenuController
{
    Menu current;
    Menu last;

    // Linked list of all menus.
    Menu list;

    /**
     * Finds a menu within the linked list with a matching `name` and sets it as the active menu.
     * Returns FALSE if no matching menu found.
     */ 
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

    /**
     * Internal helper function to register menus into the linked list.
     */
    virtual void(Menu menu) registerMenu =
    {
        if (list == world) {
            list = menu;
        } else {
            Menu start = list;
            while (start.next != world) {
                start = start.next;
            }

            start.next = menu;
        }
    };

    /**
     * A bit gross, but for now all menus need be manually registered here.
     */ 
    virtual void() registerMenus =
    {
        CharacterStartMenu cbStart = spawn(CharacterStartMenu);
        registerMenu(cbStart);

        // testing/debug, remove later
        setMenu("ch_start");
    };

    void() MenuController
    {
        registerMenus();
    };
};
