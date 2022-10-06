page 110013 "DMTCopyTableList"
{
    Caption = 'DMT Copy Table List', Comment = 'DMT Tabelle kopieren Übersicht';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "DMTCopyTable";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = "Table Caption";
                field("Table No."; Rec."Table No.") { ApplicationArea = All; }
                field("Table Caption"; Rec."Table Caption") { ApplicationArea = All; }
                field(SourceCompany; Rec.SourceCompany) { ApplicationArea = All; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Context Description"; Rec."Context Description") { ApplicationArea = All; }
                field("No. of Records"; Rec."No. of Records") { ApplicationArea = All; }
                field("No. of Records failed"; Rec."No. of Records failed") { ApplicationArea = All; }
                field("No. of Records imported"; Rec."No. of Records imported") { ApplicationArea = All; }
                field("Processing Time"; Rec."Processing Time") { ApplicationArea = All; }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.Setfilter(ExcludeSourceCompanyFilter, '<>%1', CompanyName);
    end;
}