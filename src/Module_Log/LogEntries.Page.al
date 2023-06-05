page 73002 "DMTLogEntries"
{
    Caption = 'DMT Log Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = DMTLogEntry;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Usage; Rec.Usage) { ApplicationArea = All; }
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = All; }
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; Visible = false; }
                field("Process No."; Rec."Process No.") { ApplicationArea = All; Visible = false; }
                field("Source ID (Text)"; Rec."Source ID (Text)") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(Errortext; Rec."Context Description") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(CallStack; CallStack)
                {
                    Caption = 'Error Call Stack';

                    trigger OnDrillDown()
                    begin
                        Message(Rec.GetErrorCallStack());
                    end;
                }
                field("Error Field Value"; Rec."Error Field Value") { ApplicationArea = All; }
                field(ErrorCode; Rec.ErrorCode) { ApplicationArea = All; }
                field("Ignore Error"; Rec."Ignore Error") { ApplicationArea = All; }
                field(SystemCreatedAt; Rec.SystemCreatedAt) { ApplicationArea = All; }
                field("Target Field No."; Rec."Target Field No.") { ApplicationArea = All; }
                field("Target ID (Text)"; Rec."Target ID (Text)") { ApplicationArea = All; }
                field("Target Table No."; Rec."Target Table ID") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(HideIgnored)
            {
                Caption = 'Hide ignored Errors', comment = 'Ignorierte Fehler ausblenden';
                ApplicationArea = All;
                Image = ShowList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = ShowIgnoredErrorLines;

                trigger OnAction()
                begin
                    Rec.SetRange("Ignore Error", false);
                    ShowIgnoredErrorLines := false;
                end;
            }
            action(ShowIgnored)
            {
                Caption = 'Show ignored Errors', comment = 'Ignorierte Fehler anzeigen';
                ApplicationArea = All;
                Image = ShowList;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Visible = not ShowIgnoredErrorLines;

                trigger OnAction()
                begin
                    Rec.SetRange("Ignore Error");
                    ShowIgnoredErrorLines := true;
                end;
            }
            action(DeleteFilteredLines)
            {
                Caption = 'Delete filtered lines', Comment = 'Gefilterte Zeilen löschen';
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;


                trigger OnAction()
                begin
                    if not Rec.IsEmpty() then
                        Rec.DeleteAll();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CallStack := Rec.GetErrorCallStack();
        // format Ignored Entries  
        LineStyle := Format(Enum::DMTFieldStyle::None);
        if Rec."Ignore Error" then
            LineStyle := Format(Enum::DMTFieldStyle::Grey);
    end;

    var
        CallStack, LineStyle : Text;
        [InDataSet]
        ShowIgnoredErrorLines: Boolean;
}

