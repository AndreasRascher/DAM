page 110023 DMTDataFileFactBox
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
                group(TableInfo)
                {
                    Caption = 'No. of Records in';
                    field("No. of Records In Trgt. Table"; CurrDataFile."No. of Records In Trgt. Table")
                    {
                        Caption = 'Target';
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
                    Caption = 'Data File Properties', Comment = 'Datei Eigenschaften';
                    field(GetFileSizeInKB; CurrDataFile.GetFileSizeInKB()) { Caption = 'Size(KB)'; ApplicationArea = All; }
                    field("Created At"; CurrDataFile."Created At") { ApplicationArea = All; }
                }
                repeater(Log)
                {
                    field(SystemCreatedAt; Rec.SystemCreatedAt) { ApplicationArea = All; Visible = false; }
                    field(Usage; Rec.Usage) { ApplicationArea = All; }
                    field("Context Description"; Rec."Context Description") { ApplicationArea = All; }
                }
            }

            // group("Import Duration")
            // {
            //     Caption = 'Import Duration';
            //     field("Import Duration (Buffer)"; Rec."Import Duration (Buffer)") { Caption = 'Buffer'; ApplicationArea = All; }
            //     field("Import Duration (Target)"; Rec."Import Duration (Target)") { Caption = 'Target'; ApplicationArea = All; }
            // }
            // group("Last Import")
            // {
            //     Caption = 'Last Import';
            //     field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; }
            //     field(LastImportToBufferAt; Rec.LastImportToBufferAt) { Caption = 'Buffer'; ApplicationArea = All; }
            //     field(LastImportToTargetAt; Rec.LastImportToTargetAt) { Caption = 'Target'; ApplicationArea = All; }
            // }

        }
    }
    procedure UpdateFactBoxOnAfterGetCurrRecord(dataFile: Record DMTDataFile)
    begin
        CurrDataFile.Copy(dataFile);
        CurrDataFile.InitFlowFilters();
        CurrDataFile.CalcFields("No. of Records In Trgt. Table");
        Rec.SetRange("Target Table ID", dataFile."Target Table ID");
        Rec.SetRange("Entry Type", Rec."Entry Type"::Summary);
    end;

    var
        CurrDataFile: Record DMTDataFile;
}

