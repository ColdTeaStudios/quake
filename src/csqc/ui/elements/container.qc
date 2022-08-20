class Container : UIElement
{
    // We need to reflow on size changes
    virtual void(vector _size) setSize =
    {
        dprint("Container::setSize called\n");
        size = _size;

        scroll_size.x = _size.x > scroll_size.x ? _size.x : scroll_size.x;
        scroll_size.y = _size.y > scroll_size.y ? _size.y : scroll_size.y;

        UIElement child = children;
        while (child != world) {

            child = child.next_element;
        }
    };
};
