// page 110001 "DMT Error Log List"
// {
//     Caption = 'DMT Error Log', comment = 'DMT Fehlerprotokoll';
//     PageType = List;
//     SourceTable = DMTErrorLog;
//     UsageCategory = None;
//     ModifyAllowed = false;
//     InsertAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field("Entry No."; Rec."Entry No.") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("From ID"; Rec."From ID (Text)") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("To ID"; Rec."To ID (Text)") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("From Field Caption"; Rec."From Field Caption") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("To Field Caption"; Rec."To Field Caption") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field(Errortext; Rec.Errortext) { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field(ErrorCode; Rec.ErrorCode) { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("Ignore Error"; Rec."Ignore Error") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("DMT User"; Rec."DMT User") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field("DMT Errorlog Created At"; Rec."DMT Errorlog Created At") { ApplicationArea = All; StyleExpr = TextStyle; }
//                 field(ErrorCallstack; Rec.ErrorCallstack)
//                 {
//                     ApplicationArea = All;
//                     StyleExpr = TextStyle;
//                     trigger OnDrillDown()
//                     begin
//                         Message(Rec.ReadErrorCallStack());
//                     end;
//                 }
//             }
//         }
//     }
//     actions
//     {
//         area(Processing)
//         {
//             action(HideIgnored)
//             {
//                 Caption = 'Hide ignored Errors', comment = 'Ignorierte Fehler ausblenden';
//                 ApplicationArea = All;
//                 Image = ShowList;
//                 Promoted = true;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;
//                 PromotedCategory = Process;
//                 Visible = ShowIgnoredErrorLines;

//                 trigger OnAction()
//                 begin
//                     Rec.SetRange("Ignore Error", false);
//                     ShowIgnoredErrorLines := false;
//                 end;
//             }
//             action(ShowIgnored)
//             {
//                 Caption = 'Show ignored Errors', comment = 'Ignorierte Fehler anzeigen';
//                 ApplicationArea = All;
//                 Image = ShowList;
//                 Promoted = true;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;
//                 PromotedCategory = Process;
//                 Visible = not ShowIgnoredErrorLines;

//                 trigger OnAction()
//                 begin
//                     Rec.SetRange("Ignore Error");
//                     ShowIgnoredErrorLines := true;
//                 end;
//             }
//             action(DeleteFilteredLines)
//             {
//                 Caption = 'Delete filtered lines', Comment = 'Gefilterte Zeilen löschen';
//                 ApplicationArea = All;
//                 Image = Delete;
//                 Promoted = true;
//                 PromotedIsBig = true;
//                 PromotedOnly = true;
//                 PromotedCategory = Process;


//                 trigger OnAction()
//                 begin
//                     if not Rec.IsEmpty() then
//                         Rec.DeleteAll();
//                 end;
//             }
//             action(ShowSummary)
//             {
//                 Caption = 'Summary', Comment = 'Zusammenfassung';
//                 ApplicationArea = All;
//                 Promoted = true;
//                 PromotedOnly = true;
//                 Image = Statistics;
//                 trigger OnAction()
//                 begin
//                     Rec.ShowSummary();
//                 end;
//             }
//         }
//     }

//     trigger OnAfterGetRecord()
//     begin
//         TextStyle := SetStyle();
//     end;

//     local procedure SetStyle(): Text
//     begin
//         if Rec."Ignore Error" then
//             //exit('Subordinate');
//             exit('Ambiguous');
//         exit('');
//     end;

//     var
//         [InDataSet]
//         ShowIgnoredErrorLines: Boolean;
//         [InDataSet]
//         TextStyle: Text;
// }
