page 110023 "DMTDataFileFactBox"
{
    Caption = 'DataFile FactBox';
    PageType = CardPart;
    SourceTable = DMTDataFile;

    layout
    {
        area(content)
        {
            group(FileInfo)
            {
                Caption = 'Data File Properties', Comment = 'Datei Eigenschaften';
                field(GetFileSizeInKB; Rec.GetFileSizeInKB()) { Caption = 'Size(KB)'; ApplicationArea = All; }
                field("Created At"; Rec."Created At") { ApplicationArea = All; }
            }

            group("Import Duration")
            {
                Caption = 'Import Duration';
                field("Import Duration (Buffer)"; Rec."Import Duration (Buffer)") { Caption = 'Buffer'; ApplicationArea = All; }
                field("Import Duration (Target)"; Rec."Import Duration (Target)") { Caption = 'Target'; ApplicationArea = All; }
            }
            group("Last Import")
            {
                Caption = 'Last Import';
                field(LastImportBy; Rec.LastImportBy) { ApplicationArea = All; }
                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { Caption = 'Buffer'; ApplicationArea = All; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { Caption = 'Target'; ApplicationArea = All; }
            }
            group(TableInfo)
            {
                Caption = 'No. of Records in';
                field("No. of Records In Trgt. Table"; Rec."No. of Records In Trgt. Table")
                {
                    Caption = 'Target';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        Rec.ShowTableContent(Rec."Target Table ID");
                    end;
                }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table")
                {
                    Caption = 'Buffer';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        Rec.ShowBufferTable();
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.InitFlowFilters();
    end;
}

