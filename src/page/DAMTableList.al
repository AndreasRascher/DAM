page 91003 "DAMTableList"
{
    CaptionML = DEU = 'DAM Tabellenübersicht', ENU = 'DAM Table List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMTable;
    CardPageId = DAMTableCard;

    layout
    {
        area(Content)
        {
            repeater(DAMTableRepeater)
            {
                field("From Table Caption"; Rec."From Table Caption")
                {
                    ToolTip = 'Specifies the value of the From Table Caption field.';
                    ApplicationArea = All;
                }
                field("To Table Caption"; Rec."To Table Caption")
                {
                    ToolTip = 'Specifies the value of the To Table Caption field.';
                    ApplicationArea = All;
                }
                field("Import XMLPort ID"; Rec."Import XMLPort ID")
                {
                    ToolTip = 'Specifies the value of the Import XMLPort ID field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}