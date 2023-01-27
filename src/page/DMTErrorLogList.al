page 110001 "DMT Error Log List"
{
    Caption = 'DMT Error Log', comment = 'DMT Fehlerprotokoll';
    PageType = List;
    SourceTable = DMTErrorLog;
    UsageCategory = None;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
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
                field("DMT User"; Rec."DMT User") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("DMT Errorlog Created At"; Rec."DMT Errorlog Created At") { ApplicationArea = All; StyleExpr = TextStyle; }
                field(ErrorCallstack; Rec.ErrorCallstack)
                {
                    ApplicationArea = All;
                    StyleExpr = TextStyle;
                    trigger OnDrillDown()
                    begin
                        Message(Rec.ReadErrorCallStack());
                    end;
                }
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
            action(AddTableFilter)
            {
                Caption = 'TableFilter', Comment = 'Tabellenfilter';
                ApplicationArea = All;
                Image = FilterLines;
                Promoted = true;

                trigger OnAction()
                var
                    allObjWithCaption: Record AllObjWithCaption;
                    NAVAppInstalledApp: Record "NAV App Installed App";
                    selection: Integer;
                    mI: ModuleInfo;
                    choices: Text;
                begin
                    NavApp.GetCurrentModuleInfo(mI);
                    NAVAppInstalledApp.SetRange("App ID", mI.Id);
                    NAVAppInstalledApp.FindFirst();
                    allObjWithCaption.SetRange("App Package ID", NAVAppInstalledApp."Package ID");
                    allObjWithCaption.SetRange("Object Type", allObjWithCaption."Object Type"::Table);
                    allObjWithCaption.SetFilter("Object ID", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7',
                        Database::DMTSetup,
                        Database::DMTErrorLog,
                        Database::DMTDataFile,
                        Database::DMTFieldMapping,
                        Database::DMTFieldBuffer,
                        Database::DMTGenBuffTable,
                        Database::DMTReplacementsHeaderOLD,
                        Database::DMTReplacementsLineOLD);
                    if allObjWithCaption.FindSet() then
                        repeat
                            choices += ConvertStr(allObjWithCaption."Object Caption", ',', '_') + ',';
                        until allObjWithCaption.Next() = 0;
                    choices := choices.TrimEnd(',');
                    selection := StrMenu(choices);
                    if selection = 0 then exit;
                    allObjWithCaption.Find('-');
                    if selection > 1 then
                        allObjWithCaption.Next(selection - 1);
                    Rec.SetRange("Import from Table No.", allObjWithCaption."Object ID");
                    CurrPage.Update(false);

                end;

            }
            action(ShowSummary)
            {
                Caption = 'Summary', Comment = 'Zusammenfassung';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = Statistics;
                trigger OnAction()
                begin
                    Rec.ShowSummary();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TextStyle := SetStyle();
    end;

    local procedure SetStyle(): Text
    begin
        if Rec."Ignore Error" then
            //exit('Subordinate');
            exit('Ambiguous');
        exit('');
    end;

    var
        [InDataSet]
        ShowIgnoredErrorLines: Boolean;
        [InDataSet]
        TextStyle: Text;
}
