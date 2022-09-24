page 110027 "DMTDataFileList"
{
    Caption = 'DMT Data File List';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTDataFile;
    SourceTableView = sorting("Sort Order", "Target Table ID");
    CardPageId = DMTDataFileCard;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Target Table ID"; Rec."Target Table ID") { ApplicationArea = All; }
                field("Target Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(ID; Rec.ID) { ApplicationArea = All; Visible = false; }
                field("Sort Order"; Rec."Sort Order") { ApplicationArea = All; }
                field("Table Relations"; Rec."Table Relations") { ApplicationArea = All; }
                field(Size; Rec.Size) { ApplicationArea = All; }
                field("No.of Records in Buffer Table"; Rec."No.of Records in Buffer Table") { ApplicationArea = All; }
                field("No. of Records In Trgt. Table"; Rec."No. of Records In Trgt. Table") { ApplicationArea = All; }
                field(LastImportToBufferAt; Rec.LastImportToBufferAt) { ApplicationArea = All; }
                field(LastImportToTargetAt; Rec.LastImportToTargetAt) { ApplicationArea = All; }
                field("Created At"; Rec."Created At") { ApplicationArea = All; }
                field("Import XMLPort ID"; Rec."Import XMLPort ID") { ApplicationArea = All; }
                field("Buffer Table ID"; Rec."Buffer Table ID") { ApplicationArea = All; }
                field(BufferTableType; Rec.BufferTableType) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(ActionName)
            // {
            //     ApplicationArea = All;

            //     trigger OnAction();
            //     begin

            //     end;
            // }
        }
    }
}