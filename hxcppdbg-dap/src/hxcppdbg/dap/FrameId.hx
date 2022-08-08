package hxcppdbg.dap;

abstract FrameId(Int) to Int
{
    public var thread (get, never) : Int;

    public function get_thread()
    {
        return (this >> 16) & 0xffff;
    }

    public var number (get, never) : Int;

    public function get_number()
    {
        return this & 0xffff;
    }

    public function new(_threadIndex, _frameIndex)
    {
        this = ((_threadIndex & 0xffff) << 16) | (_frameIndex & 0xffff);
    }
}