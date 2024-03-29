page 73021 "DMT Setup"
{
    Caption = 'Data Migration Tool Setup', comment = 'Data Migration Tool Einrichtung';
    AdditionalSearchTerms = 'DMT Setup', Comment = 'DMT Einrichtung';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTSetup;
    PromotedActionCategories = 'NAV,Backup,Lists,,', Comment = 'NAV,Backup,Listen,,';

    layout
    {
        area(Content)
        {
            group("Global Settings")
            {
                Caption = 'Global Settings', Comment = 'Globale Einstellungen';
                group(ObjectIDs)
                {
                    Caption = 'Object IDs', comment = 'Objekt IDs';
                    field("Obj. ID Range Buffer Tables"; Rec."Obj. ID Range Buffer Tables") { ApplicationArea = All; ShowMandatory = true; }
                    field("Obj. ID Range XMLPorts"; Rec."Obj. ID Range XMLPorts") { ApplicationArea = All; ShowMandatory = true; }
                }
                group(Paths)
                {
                    Caption = 'Paths', comment = 'Pfade';
                    field("Default Export Folder Path"; Rec."Default Export Folder Path") { ApplicationArea = All; }
                    field("Backup.xml File Path"; Rec."Backup.xml File Path") { ApplicationArea = All; }
                }
                group(Debugging)
                {
                    field(SessionID; SessionId())
                    {
                        ApplicationArea = All;
                        Caption = 'SessionID';
                        trigger OnAssistEdit()
                        var
                            activeSession: Record "Active Session";
                            Choice: Integer;
                            NoOfChoices: Integer;
                            SessionListID: Integer;
                            // IsDebugging, IsDebugged, IsSQLTracing : Boolean;
                            StopSessionInstructionLbl: Label 'Select which session to stop:\<Session ID> - <User ID> - <Client Type>- <Login Datetime>', Comment = 'Wählen Sie eine Session zum Beenden aus:\<Session ID> - <User ID> - <Client Type> - <Login Datetime>';
                            SessionList: List of [Integer];
                            Choices: Text;
                        begin
                            if activeSession.FindSet() then
                                repeat

                                    // IsDebugging := DEBUGGER.ISACTIVE AND (activeSession."Session ID" = debugger.DebuggingSessionID());
                                    // IsSQLTracing := DEBUGGER.ENABLESQLTRACE(activeSession."Session ID");
                                    Choices += StrSubstNo('%1 - %2 - %3 - %4,', activeSession."Session ID", activeSession."User ID", activeSession."Client Type", activeSession."Login Datetime");
                                    NoOfChoices += 1;
                                    SessionList.Add(activeSession."Session ID");
                                until activeSession.Next() = 0;
                            Choices += 'StopAllOtherSessions,';
                            Choices += 'Cancel';
                            Choice := StrMenu(Choices, NoOfChoices + 2, StopSessionInstructionLbl);
                            if Choice <> 0 then
                                case true of
                                    //StopAllOtherSessions
                                    (Choice = NoOfChoices + 1):
                                        begin
                                            foreach SessionListID in SessionList do begin
                                                if SessionId() <> SessionListID then
                                                    if StopSession(SessionListID) then;
                                            end;
                                        end;
                                    //Cancel
                                    (Choice = NoOfChoices + 2):
                                        begin

                                        end;
                                end;
                            if Choice <= NoOfChoices then begin
                                if Choice <> 0 then // Cancel Menu
                                    Message('%1', StopSession(SessionList.Get(Choice)));
                            end;
                        end;
                    }
                    field(UserID; UserId) { ApplicationArea = All; Caption = 'User ID'; }
                }
            }
            group("Company Settings")
            {
                Caption = 'Company Settings', Comment = 'Mandanteneinstellungen';
                group(CompanyPaths)
                {
                    Caption = 'Paths', comment = 'Pfade';
                    field("Schema File Path"; Rec."Schema.csv File Path") { ApplicationArea = All; }
                }
                group(Performance)
                {
                    field("Import with FlowFields"; Rec."Import with FlowFields") { ApplicationArea = All; }
                }

            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(ImportNAVSchema)
            {
                Caption = 'Import Schema.csv', comment = 'NAV Schema.csv importieren';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                var
                    ObjMgt: Codeunit DMTObjMgt;
                begin
                    ObjMgt.ImportNAVSchemaFile();
                end;
            }
            action(FindValidObjIDRanges)
            {
                Caption = 'Find available Object ID ranges', comment = 'Verfügbare Objekt-ID Bereiche ermitteln';
                ApplicationArea = All;
                Image = DataEntry;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = New;

                trigger OnAction()
                begin
                    Rec.ProposeObjectRanges();
                end;
            }
        }
        area(Reporting)
        {
            action(Table_DMTFieldBuffer)
            {
                ApplicationArea = All;
                Caption = 'Show Schema Data', comment = 'Schema Daten anzeigen';
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                Image = ShowMatrix;
                // Visible = false;

                trigger OnAction()
                begin
                    Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, Database::DMTFieldBuffer));
                end;
            }
            action(ClearGenBuffer)
            {
                Caption = 'Delete Gen. Buffer Table Lines', comment = 'Alle Zeilen in gen. Puffertabelle löschen';
                ApplicationArea = All;
                Image = ListPage;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    DMTGenBuffTable: Record DMTGenBuffTable;
                begin
                    if Confirm('Delete all lines in Gen. Buffer Table?') then
                        DMTGenBuffTable.DeleteAll();
                end;
            }
        }
        area(Processing)
        {
            action(XMLExport)
            {
                Caption = 'Create Backup', Comment = 'de-DE=Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Export();
                end;
            }
            action(XMLImport)
            {
                Caption = 'Import Backup', Comment = 'Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    DataFile: Record DMTDataFile;
                    PageActions: Codeunit DMTDataFilePageAction;
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Import();
                    // Update imported "Qty.Lines In Trgt. Table" with actual values
                    if DataFile.FindSet() then
                        repeat
                            PageActions.UpdateQtyLinesInBufferTable(DataFile);
                        until DataFile.Next() = 0;
                end;
            }
        }

    }
    trigger OnOpenPage()
    begin
        Rec.InsertWhenEmpty();
    end;
}