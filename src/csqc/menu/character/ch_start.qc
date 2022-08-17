
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

    void() CharacterStartMenu =
    {
        name = "ch_start";

        Container container = spawn(Container);
        container.position = [320, 200, 0];
        container.size = [320, 240, 0];
        container.border_width = 1;
        container.border_color = [0.7, 0.7, 0.7];
        container.border_color_hover = [0.7, 0.7, 0.7];
        container.background_color = [0.169, 0.165, 0.2];
        container.background_color_hover = [0.169, 0.165, 0.2];
        container.background_color_opacity = 1.0;
        container.background_color_opacity_hover = 1.0;
        container.padding = [32, 32, 0];

        container.background_image = "gfx/adsb_shells.lmp";
        container.background_image_opacity = 1;
        container.background_image_hover_opacity = 1;
        container.background_size_mode = W_BG_SZ_PIXELS;
        container.background_repeat = TRUE;
        addElement(container);

        Button btnClose = spawn(Button);
        btnClose.position = [32, 32, 0];
        btnClose.onClick = closeOnClick;
        btnClose.size = [64, 16, 0];
        btnClose.text = "Spectate";
        container.addElement(btnClose);

        btnClose.tooltip = NewTooltip("This is a tooltip!");
        btnClose.tooltip.parent = btnClose;
    };

    virtual void() onOpen = {
        // TODO send request for updated char list from server
    };
};
