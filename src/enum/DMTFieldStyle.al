enum 110004 "DMTFieldStyle"
{
    Extensible = true;

    value(0; None) { Caption = 'None', Locked = true; }
    value(1; Standard) { Caption = 'Standard', Locked = true; }
    value(2; Blue) { Caption = 'StandardAccent', Locked = true; }
    value(3; Bold) { Caption = 'Strong', Locked = true; }
    value(4; "Blue + Bold") { Caption = 'StrongAccent', Locked = true; }
    value(5; "Red + Italic") { Caption = 'Attention', Locked = true; }
    value(6; "Blue + Italic") { Caption = 'AttentionAccent', Locked = true; }
    value(7; "Bold + Green") { Caption = 'Favorable', Locked = true; }
    value(8; "Bold + Italic + Red") { Caption = 'Unfavorable', Locked = true; }
    value(9; Yellow) { Caption = 'Ambiguous', Locked = true; }
    value(10; Grey) { Caption = 'Subordinate', Locked = true; }
}