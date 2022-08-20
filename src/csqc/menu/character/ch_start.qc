class CharacterStartMenu : Menu
{
    virtual float(UIElement target) mainMenuOnClick =
    {
        dprint("mainMenuOnClick");
        return TRUE;
    };

    virtual float(UIElement target) closeOnClick =
    {
        dprint("closeOnClick\n");
        return TRUE;
    };

    virtual float(UIElement target) addButtonOnClick =
    {
        dprint("AddButtonOnClick\n");

        vector bgColor = [random(), random(), random()];

        UIElement el = spawn(UIElement);
        el.setSize([32, 32]);
        el.setMargin(8, 8, 8, 8);
        el.background_color = bgColor;
        el.background_color_hover = bgColor;
        el.background_color_opacity = 1.0;
        el.background_color_opacity_hover = 1.0;
        ((Container) target.parent).addElement(el);
        dprint("adding\n");

        return TRUE;
    };

    virtual float(UIElement target) marginUpOnClick =
    {
        UIElement el = target.parent.children;
        while (el != world) {
            el.setMargin(el.margin[0], el.margin[1]+1, el.margin[2], el.margin[3]+1);
            el = el.next_element;
        }

        return TRUE;
    };

    virtual float(UIElement target) marginDownOnClick =
    {
        UIElement el = target.parent.children;
        while (el != world) {
            el.setMargin(el.margin[0], el.margin[1]-1, el.margin[2], el.margin[3]-1);
            el = el.next_element;
        }

        return TRUE;
    };

    void() CharacterStartMenu =
    {
        name = "ch_start";

        Container container = spawn(Container);
        container.position = [320, 200];
        container.size = [320, 240];
        container.setBorderWidth(1, 1, 1, 1);
        container.border_color = [95, 71, 7];
        container.border_color_hover = [107, 75, 11];
        container.background_color = [0.169, 0.165, 0.2];
        container.background_color_hover = [0.169, 0.165, 0.2];
        container.background_color_opacity = 1.0;
        container.background_color_opacity_hover = 1.0;
        container.setPadding(32, 32, 32, 32);

        container.background_image = "gfx/conback.lmp";
        container.background_image_opacity = 1;
        container.background_image_hover_opacity = 1;
        container.background_size_mode = W_BG_SZ_COVER;
        container.background_repeat = TRUE;
        addElement(container);

        Button btnClose = spawn(Button);
        btnClose.position = [8, 8];
        btnClose.position_mode = W_POS_ABSOLUTE;
        btnClose.onClick = addButtonOnClick;
        btnClose.size = [32, 16, 0];
        btnClose.text = "Add";
        container.addElement(btnClose);

        Button btnMarginUp = spawn(Button);
        btnMarginUp.position = [48, 8];
        btnMarginUp.position_mode = W_POS_ABSOLUTE;
        btnMarginUp.onClick = marginUpOnClick;
        btnMarginUp.size = [16, 16, 0];
        btnMarginUp.text = "+";
        container.addElement(btnMarginUp);

        Button btnMarginDown = spawn(Button);
        btnMarginDown.position = [72, 8];
        btnMarginDown.position_mode = W_POS_ABSOLUTE;
        btnMarginDown.onClick = marginDownOnClick;
        btnMarginDown.size = [16, 16, 0];
        btnMarginDown.text = "-";
        container.addElement(btnMarginDown);

        btnClose.tooltip = NewTooltip("This is a tooltip!");
    };

    virtual void() onOpen = {
        // TODO send request for updated char list from server
    };
};
