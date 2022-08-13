
class CharacterStartMenu : Menu
{
    virtual float(Widget target) mainMenuOnClick =
    {
        dprint("mainMenuOnClick");
        return TRUE;
    };

    virtual float(Widget target) closeOnClick =
    {
        dprint("closeOnClick\n");
        return TRUE;
    };

    void() CharacterStartMenu =
    {
        name = "ch_start";

        Container container = spawn(Container);
        container.position = [0, 0, 0];
        container.size = [320, 240, 0];
        container.border_width = 1;
        container.border_color = [0.7, 0.7, 0.7];
        container.background_color = [0.169, 0.165, 0.2];
        container.padding = [32, 32, 0];
        addWidget(container);

        Button btnClose = spawn(Button);
        btnClose.position = [32, 32, 0];
        btnClose.onClick = closeOnClick;
        btnClose.size = [56, 16, 0];
        btnClose.text = "Spectate";
        container.addWidget(btnClose);
    };

    virtual void() onOpen = {
        // TODO send request for updated char list from server
    };
};
