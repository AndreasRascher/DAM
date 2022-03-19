page 91001 "DMT Error Log List"
{
    ApplicationArea = All;
    CaptionML = DEU = 'DMT Fehlerprotokoll', ENU = 'DMT Error Log';
    PageType = List;
    SourceTable = DMTErrorLog;
    UsageCategory = Lists;
    ModifyAllowed = false;
    InsertAllowed = false;

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
                field("DMT User"; Rec."DMT User") { ApplicationArea = All; StyleExpr = TextStyle; }
                field("DMT Errorlog Created At"; Rec."DMT Errorlog Created At") { ApplicationArea = All; StyleExpr = TextStyle; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(HideIgnored)
            {
                CaptionML = DEU = 'Ignorierte Fehler ausblenden', ENU = 'Hide ignored Errors';
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
                CaptionML = DEU = 'Ignorierte Fehler anzeigen', ENU = 'Show ignored Errors';
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
                CaptionML = DEU = 'Gefilterte Zeilen löschen', ENU = 'Delete filtered lines';
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;


                trigger OnAction()
                begin
                    Rec.DeleteAll();
                end;
            }
            action(AddTableFilter)
            {
                CaptionML = DEU = 'Tabellenfilter', ENU = 'TableFilter';
                ApplicationArea = all;
                Image = FilterLines;
                Promoted = true;

                trigger OnAction()
                var
                    allObjWithCaption: Record AllObjWithCaption;
                    NAVAppInstalledApp: Record "NAV App Installed App";
                    selection: Integer;
                    mI: ModuleInfo;
                    choices: text;
                begin
                    NavApp.GetCurrentModuleInfo(mI);
                    NAVAppInstalledApp.SetRange("App ID", mI.Id);
                    NAVAppInstalledApp.FindFirst();
                    allObjWithCaption.SetRange("App Package ID", NAVAppInstalledApp."Package ID");
                    allObjWithCaption.Setrange("Object Type", allObjWithCaption."Object Type"::Table);
                    allObjWithCaption.SetFilter("Object ID", '<>%1&<>%2&<>%3&<>%4&<>%5&<>%6',
                        Database::"DMTSetup",
                        Database::DMTErrorLog,
                        Database::"DMTField",
                        Database::DMTFieldBuffer,
                        Database::DMTTable,
                        Database::DMTGenBuffTable);
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


                    //                     IF Object.FIND('-') THEN
                    //                         REPEAT
                    //                             Object.CALCFIELDS(Caption);
                    //                             Choices += CONVERTSTR(Object.Caption, ',', '_') + ',';
                    //                         UNTIL Object.NEXT = 0;
                    //                     IF Choices <> '' THEN
                    //                         Choices := COPYSTR(Choices, 1, STRLEN(Choices) - 1);
                    //                     Selection := STRMENU(Choices);
                    //                     IF Selection = 0 THEN
                    //                         EXIT;
                    //                     Object.FIND('-');
                    //                     IF Selection > 1 THEN
                    //                         Object.NEXT(Selection - 1);
                    //                     SETRANGE("Import from Buffertable No.", Object.ID);
                    //                     CurrPage.UPDATE(FALSE);

                    //                     AddContextFilter - OnAction()
                    // DMTErrorLog.OPEN;
                    //                     WHILE DMTErrorLog.READ DO BEGIN
                    //                         ResultTextArr[COMPRESSARRAY(ResultTextArr) + 1] := DMTErrorLog.DMT_Context_Descr;
                    //                     END;
                    //                     FOR Index := 1 TO ARRAYLEN(ResultTextArr) DO BEGIN
                    //                         Choices += CONVERTSTR(ResultTextArr[Index], ',', '_') + ',';
                    //                     END;
                    //                     IF Choices <> '' THEN
                    //                         Choices := COPYSTR(Choices, 1, STRLEN(Choices) - 1);
                    //                     Selection := STRMENU(Choices);
                    //                     IF Selection = 0 THEN
                    //                         EXIT;

                    //                     IF Selection > 1 THEN
                    //                         SETRANGE("DMT Context Descr.", ResultTextArr[Selection]);
                    //                     CurrPage.UPDATE(FALSE);

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
        IF Rec."Ignore Error" then
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
