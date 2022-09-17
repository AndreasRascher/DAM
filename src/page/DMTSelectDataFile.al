page 110025 "DMTSelectDataFile"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTDataFileBuffer;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            field(HasSchema; IsNAVSchemaFileImported()) { Caption = 'Schema Data Found'; ApplicationArea = All; }
            repeater(repeater)
            {
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("DateTime"; Rec."DateTime") { ApplicationArea = All; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.") { ApplicationArea = All; }
                field("Target Table ID"; Rec."Target Table ID") { ApplicationArea = All; }
                field("NAV Src.Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; Visible = false; }
                field("Target Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; Visible = false; }
                field("NAV Src.Table Name"; Rec."NAV Src.Table Name") { ApplicationArea = All; Visible = false; }
                field(Path; Rec.Path) { ApplicationArea = All; Visible = false; }
                field(Size; Rec.Size) { ApplicationArea = All; }
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

            //     trigger OnAction()
            //     begin

            //     end;
            // }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.LoadFiles();
    end;

    procedure GetSelection(var DataFileBuffer_Selected: Record DMTDataFileBuffer temporary) HasLines: Boolean
    var
        DMTDataFileBuffer: Record DMTDataFileBuffer;
    begin
        Clear(DataFileBuffer_Selected);
        if DataFileBuffer_Selected.IsTemporary then
            DataFileBuffer_Selected.DeleteAll();
        DMTDataFileBuffer.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(DMTDataFileBuffer);
        // DMTDataFileBuffer.CopyToTemp(DataFileBuffer_Selected);
        HasLines := DataFileBuffer_Selected.FindFirst();
    end;

    procedure IsNAVSchemaFileImported(): Boolean
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
    begin
        exit(not DMTFieldBuffer.IsEmpty);
    end;
}