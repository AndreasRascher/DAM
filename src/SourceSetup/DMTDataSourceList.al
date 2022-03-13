page 91009 DataSourceList
{
    ApplicationArea = All;
    CaptionML = ENU = 'Data Source List', DEU = 'Datenquellen Übersicht';
    PageType = List;
    SourceTable = DMTDataSourceHeader;
    UsageCategory = Lists;
    CardPageId = "Data Source Card";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                CaptionML = ENU = 'General', DEU = 'Allgemein';
                field("No."; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Data Source Type"; Rec."Data Source Type") { ApplicationArea = All; }
                field(FileName; Rec.FileName) { ApplicationArea = All; }
                field(FilePath; Rec.FilePath) { ApplicationArea = All; }
                field("CSV Field Delimiter"; Rec."CSV Field Delimiter") { ApplicationArea = All; }
                field("CSV Field Seperator"; Rec."CSV Field Seperator") { ApplicationArea = All; }
                field("CSV Record Seperator"; Rec."CSV Record Seperator") { ApplicationArea = All; }
                field("NAV Schema File Status"; Rec."NAV Schema File Status") { ApplicationArea = All; }
                field("NAV Src.Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; }
                field("NAV Src.Table Name"; Rec."NAV Src.Table Name") { ApplicationArea = All; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; }
            }
        }
    }
}
