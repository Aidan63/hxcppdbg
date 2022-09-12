package hxcppdbg.dap.protocol.data;

enum abstract StackFramePresentationHint(String)
{
    final Normal = 'normal';
    final Label = 'label';
    final Subtle = 'subtle';
}