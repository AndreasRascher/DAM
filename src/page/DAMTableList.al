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
                field("From Table ID"; Rec."From Table ID") { ApplicationArea = All; }
                field("From Table Caption"; Rec."From Table Caption") { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; }
                field("To Table ID"; Rec."To Table ID") { ApplicationArea = All; }
                field("To Table Caption"; Rec."To Table Caption") { ApplicationArea = All; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; }
                field(ExportFilePath; Rec.ExportFilePath) { ApplicationArea = All; }
            }
        }
    }
}