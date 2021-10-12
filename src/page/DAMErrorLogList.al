page 91001 "DAM Error Log List"
{
    ApplicationArea = All;
    CaptionML = DEU = 'DAM Fehlerprotokoll', ENU = 'DAM Error Log';
    PageType = List;
    SourceTable = DAMErrorLog;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("From ID"; Rec."From ID (Text)") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("To ID"; Rec."To ID (Text)") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("From Field Caption"; Rec."From Field Caption") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("To Field Caption"; Rec."To Field Caption") { ApplicationArea = All; StyleExpr = TextStyle; }
                field(Errortext; Rec.Errortext) { ApplicationArea = All; StyleExpr = TextStyle; }
                field(ErrorCode; Rec.ErrorCode) { ApplicationArea = All; StyleExpr = TextStyle; }
                field("Ignore Error"; Rec."Ignore Error") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("DAM User"; Rec."DAM User") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("DAM Errorlog Created At"; Rec."DAM Errorlog Created At") { ApplicationArea = All; StyleExpr = TextStyle; }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TextStyle := SetStyle();
    end;

    local procedure SetStyle(): Text
    begin
        IF Rec."Ignore Error" then
            exit('Subordinate');
        exit('');
    end;

    var
        [InDataSet]
        TextStyle: Text;
}
