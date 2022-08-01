page 110019 DataSourceCardPart
{
    Caption = 'DataSourceCardPart', Locked = true;
    PageType = ListPart;
    SourceTable = DMTDataSourceLine;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(DataSourceNo; Rec."Data Source Code") { ApplicationArea = All; Visible = false; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Column Name"; Rec."Column Name") { ApplicationArea = All; }
            }
        }
    }
}
