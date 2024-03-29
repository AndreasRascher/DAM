page 73006 DMTDataFileFactBox
{
    Caption = 'DataFile FactBox';
    PageType = ListPart;
    SourceTable = DMTLogEntry;

    layout
    {
        area(Content)
        {
            group(InfoGroups)
            {
                ShowCaption = false;
                Visible = (ViewMode = ViewMode::TableInfo);
                group(TableInfo)
                {
                    Caption = 'No. of Records in', Comment = 'de-DE=Anz. Datensätze in';
                    field("No. of Records In Trgt. Table"; CurrDataFile."No. of Records In Trgt. Table")
                    {
                        Caption = 'Target', Comment = 'de-DE=Ziel';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        begin
                            CurrDataFile.ShowTableContent(CurrDataFile."Target Table ID");
                        end;
                    }
                    field("No.of Records in Buffer Table"; CurrDataFile."No.of Records in Buffer Table")
                    {
                        Caption = 'Buffer';
                        ApplicationArea = All;
                        trigger OnDrillDown()
                        begin
                            CurrDataFile.ShowBufferTable();
                        end;
                    }
                }
                group(FileInfo)
                {
                    Caption = 'Data File Properties', Comment = 'de-DE=Datei Eigenschaften';
                    field(GetFileSizeInKB; CurrDataFile.GetFileSizeInKB()) { Caption = 'Size(KB)', Comment = 'de-DE=Größe(KB)'; ApplicationArea = All; }
                    field("Created At"; CurrDataFile."Created At") { Caption = 'Created At', Comment = 'de-DE=Erstellt am'; ApplicationArea = All; }
                }
            }
            repeater(Log)
            {
                Caption = 'Log', Comment = 'de-DE=Protokoll';
                Visible = (ViewMode = ViewMode::Log);
                field(SystemCreatedAt; Rec.SystemCreatedAt) { ApplicationArea = All; Visible = false; }
                field(Usage; Rec.Usage) { ApplicationArea = All; }
                field("Context Description"; Rec."Context Description") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenLog)
            {
                ApplicationArea = All;
                Scope = Repeater;
                Image = Log;
                Caption = 'Show Log', Comment = 'de-DE=Protoll öffnen';

                trigger OnAction()
                var
                    Log: Codeunit DMTLog;
                begin
                    Log.ShowLogEntriesFor(Rec);
                end;
            }
        }
    }

    procedure ShowAsLogAndUpdateOnAfterGetCurrRecord(dataFile: Record DMTDataFile)
    begin
        ViewMode := ViewMode::Log;
        CurrDataFile.Copy(dataFile);
        CurrDataFile.InitFlowFilters();
        CurrDataFile.CalcFields("No. of Records In Trgt. Table");
        Rec.SetRange("Target Table ID", dataFile."Target Table ID");
        Rec.SetRange("Entry Type", Rec."Entry Type"::Summary);
    end;

    procedure ShowAsTableInfoAndUpdateOnAfterGetCurrRecord(dataFile: Record DMTDataFile)
    begin
        ViewMode := ViewMode::TableInfo;
        CurrDataFile.Copy(dataFile);
        CurrDataFile.InitFlowFilters();
        CurrDataFile.CalcFields("No. of Records In Trgt. Table");
        Rec.SetRecFilter();
    end;

    var
        CurrDataFile: Record DMTDataFile;
        ViewMode: Option " ",Log,TableInfo;
}

