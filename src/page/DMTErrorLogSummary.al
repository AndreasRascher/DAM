page 110014 DMTErrorLogSummary
{
    Caption = 'ErrorLog Summary', Comment = 'Fehlerprotokoll Zusammenfassung';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTErrorLog;
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Frequency (Summary)"; Rec."Frequency (Summary)") { ApplicationArea = All; }
                field("Import to Field No."; Rec."Import to Field No.") { ApplicationArea = All; }
                field("To Field Caption"; Rec."To Field Caption") { ApplicationArea = All; }
                field(ErrorCode; Rec.ErrorCode) { ApplicationArea = All; }
                field("Error Field Value"; Rec."Error Field Value") { ApplicationArea = All; }
            }
        }
        area(FactBoxes)
        {
        }
    }

    // trigger OnAfterGetRecord()
    // begin
    //     Rec.CalcFields("To Field Caption");
    // end;

}